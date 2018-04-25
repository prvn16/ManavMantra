classdef (Hidden = true) SplittableDatastore < ...
        matlab.io.datastore.Datastore & ...
        matlab.mixin.Copyable
%SplittableDatastore    Declares the interface for divisible datastores.
%   Datastores that can divide up the tasks for reading the datastore
%   into smaller pieces (called splits) are splittable in nature and can
%   support extra functionality including getting progress from the
%   datastore and possible parallelism with mapreduce.
%
%   This class inherits from AbstractDatastore and provides default
%   implementations for the hasdata, read, and reset methods
%
%   See also datastore, mapreduce

%   Copyright 2014-2016 The MathWorks, Inc.

    % Default implementation for SplittableDatastore %
    
    properties (Access = 'protected')
        Splitter;                % Splitter instance for the datastore
    end
    
    properties (Transient, Access = 'protected')
        SplitReader;             % SplitReader instance
        SplitIdx = 0;            % current split index
    end
    
    methods        
        function tf = hasdata(ds)
        %HASDATA   Returns true if more data is available.
        %   Return logical scalar indicating availability of data. This
        %   method should be called before calling read.
        %
        %   See also READ, READALL, PREVIEW, RESET,
        %   matlab.io.datastore.TabularTextDatastore
        
            tf = false;
            
            numSplits = ds.Splitter.NumSplits;
            if numSplits == 0
                return;
            end
            
            % current split has data?
            if hasNext(ds.SplitReader)
                tf = true;
                return;
            end
            
            % any non empty split left?
            currIdx = ds.SplitIdx;
            if currIdx < numSplits
                % skip over splits without data
                for sidx = currIdx + 1 : numSplits
                    prevRdr = ds.SplitReader;
                    try
                        % point the reader to the new split beginning
                        ds.moveToSplit(sidx);
                    catch ME
                        % if it fails, set the reader and the split index
                        % to the previous split.
                        ds.SplitReader = prevRdr;
                        throw(ME)
                    end
                    
                    if hasNext(ds.SplitReader)
                        tf = true;
                        return;
                    end
                end 
            end
            
        end
        
        function reset(ds)
        %RESET   Reset to the start of the data.
        %   Reset the datastore to the state where no data has been read
        %   from it.
            
            if ~isempty(ds.Splitter) && isvalid(ds.Splitter) && ...
                ds.Splitter.NumSplits ~= 0
                ds.moveToSplit(1);
            end
        end

        function delete(ds)
        %DELETE   Delete the datastore
            if ~isempty(ds.Splitter) && isvalid(ds.Splitter)
                delete(ds.Splitter);
            end
            if ~isempty(ds.SplitReader) && ...
               isa(ds.SplitReader, 'matlab.io.datastore.splitreader.SplitReader') && ...
               isvalid(ds.SplitReader)
                delete(ds.SplitReader);
            end
        end        
    end

    methods (Hidden)
        function frac = progress(ds)
        %PROGRESS   Percentage of completed splits between 0.0 and 1.0.
        %   Return fraction between 0.0 and 1.0 indicating progress. Does
        %   not count unfinished splits
            numSplits = ds.Splitter.NumSplits;
            if numSplits == 0
                frac = 1.0;
                return;
            end
            split = ds.SplitIdx-hasNext(ds.SplitReader);
            frac = min(split/numSplits, 1.0);
        end
    end

    % Default copy implementation for SplittableDatastore
    methods (Access = 'protected')
        function dscopy = copyElement(ds)
        % COPYELEMENT   Default implementation for copying SplittableDatastore objects.
            dscopy = copyElement@matlab.mixin.Copyable(ds);
            dscopy.Splitter = copy(ds.Splitter);
            if ds.Splitter.NumSplits ~= 0 ...
            && isa(ds.SplitReader, 'matlab.io.datastore.splitreader.SplitReader')
                dscopy.SplitReader = copy(ds.SplitReader);
            end
        end

        function [data, info] = readData(ds)
        %READDATA   Read data and information about the extracted data.
        %   Return the data extracted from the datastore in the appropriate
        %   form for this datastore. Also return information about where
        %   the data was extracted from in the datastore.
        %
            if ~hasdata(ds)
                error(message(...
                    'MATLAB:datastoreio:splittabledatastore:noMoreData'));
            end
            [data, info] = getNext(ds.SplitReader);
        end

    end
    
    methods (Access = 'protected')
        function moveToSplit(ds, ii)
            rdr = createReader(ds.Splitter, ii);
            reset(rdr);
            % the above call may error, so only do sets afterwards
            ds.SplitIdx = ii;
            ds.SplitReader = rdr;
        end
    end
    
    methods
        function set.Splitter(ds, splitter)
            if ~isa(splitter, 'matlab.io.datastore.splitter.Splitter')
                error(message('MATLAB:datastoreio:splittabledatastore:invalidSplitter'));
            end
            ds.Splitter = splitter;
        end
    end

    methods
        function outds = partition(ds, N, ii)
        %PARTITION   Return a partitioned part of the datastore.
        %   This function will return a datastore that represents the part of the
        %   data corresponding with the partition and index chosen.
             
            % The actual partitioning.
            newSplitter = ds.Splitter.partitionBySubset(N, ii);
            outds = ds.copy();
            outds.Splitter = newSplitter;
            outds.reset();
        end
        
        function numPartitions = numpartitions(ds, pool)
            %NUMPARTITIONS Return an estimate for a reasonable number of partitions for the given information.
            %
            %   N = NUMPARTITIONS(DS) returns the default number of partitions for a
            %   given DATASTORE, DS.
            %
            %   N = NUMPARTITIONS(DS,POOL) returns a reasonable number of partitions
            %   to parallelize DS over the parallel pool, POOL, based on the total
            %   number of partitions and the number of workers in POOL.
            %
            %   Th number of partitions obtained from NUMPARTITIONS is recommended as
            %   an input to PARTITION function.
            %
            %   Example:
            %      % A datastore that contains 10 copies of the 'airlinesmall.csv'
            %      % example dataset.
            %      files = repmat({'airlinesmall.csv'},1,10);
            %      ds = tabularTextDatastore(files,'TreatAsMissing','NA','MissingValue',0);
            %      ds.SelectedVariableNames = 'ArrDelay';
            %
            %      N = numpartitions(ds,gcp);
            %      totalSum = 0;
            %      parfor ii = 1:N
            %          subds = partition(ds,N,ii);
            %
            %          while hasdata(subds)
            %              data = read(subds)
            %              totalSum = totalSum + sum(data.ArrDelay);
            %          end
            %      end
            %      totalSum
            %
            %   See also matlab.io.datastore.TabularTextDatastore, partition.

            try
                numWorkers = Inf;
                if nargin >= 2
                    validateattributes(pool, {'parallel.Pool'}, {}, 'numpartitions', 'pool');
                    if ~isempty(pool)
                        numWorkers = pool.NumWorkers;
                    end
                end

                % We choose 3 * numWorkers for load balancing reasons.
                numPartitions = min(numel(ds.Splitter.Splits), 3 * numWorkers);
            catch ME
                throwAsCaller(ME);
            end
        end
    end
end
