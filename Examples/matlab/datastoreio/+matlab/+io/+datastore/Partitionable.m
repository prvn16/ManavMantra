classdef Partitionable < handle
%PARTITIONABLE   Declares the interface that adds parallelization support
%   to the datastores for use in PCT/MDCS.
%   This abstract class is a mixin for subclasses of matlab.io.Datastore
%   that adds parallelization support to the datastore for use in PCT/MDCS.
%
%   Partitionable Methods:
%
%   partition       -    Return a new datastore that represents a single
%                        partitioned part of the original datastore.
%   numpartitions   -    Return an estimate for a reasonable number of
%                        partitions to use with the partition function for
%                        the given information.
%   maxpartitions   -    Return the maximum number of partitions possible for
%                        the datastore.
%
%   Partitionable Method Attributes:
%
%   partition       -    Public, Abstract
%   numpartitions   -    Public, Sealed
%   maxpartitions   -    Protected, Abstract
%
%   This class implements the numpartitions method. The partition and
%   maxpartitions methods have to be implemented by the subclasses derived
%   from the Partitionable class.
%
%   Example Implementation:
%   -----------------------
%   % Mixing in parallelization support to the datastore for use in PCT/MDCS
%   % This example template builds on the example implementation found in
%   % matlab.io.Datastore. The two example templates are meant to be used in
%   % conjunction to get a partitioned datastore.
%   classdef MyDatastore < matlab.io.Datastore & ...
%                          matlab.io.datastore.Partitionable
%       properties
%       ...
%           FileSet matlab.io.datastore.DsFileSet
%       ...
%       end
%
%       methods(Access = public)
%           function submyds = partition(myds,n,index)
%               %PARTITION Return a partitioned part of the Datastore.
%
%               %   SUBDS = PARTITION(DS,N,INDEX) partitions DS into
%               %   N parts and returns the partitioned Datastore, SUBDS,
%               %   corresponding to INDEX. An estimate for a reasonable
%               %   value for N can be obtained by using the NUMPARTITIONS
%               %   function.
%
%               % This method partitions the DsFileSet and uses the
%               % subset of the DsFileSet corresponding to the index
%               % specified in the input arguments to create a new datastore
%               submyds = copy(myds);
%               submyds.FileSet = partition(myds.FileSet,n,index);
%               reset(submyds);
%           end
%       end
%       methods(Access = protected)
%           function N = maxpartitions(ds)
%               %MAXPARTITIONS Return the maximum number of partitions
%               %   possible for the datastore.
%
%               %   N = MAXPARTITIONS(DS) returns the maximum number of
%               %   partitions for a given Datastore, DS.
%
%               % This method returns the output of maxpartitions method of
%               % the matlab.io.datastore.DsFileSet object corresponding to
%               % this datastore
%               N = maxpartitions(ds.FileSet);
%           end
%       end
%   end
%
%   Example usage:
%   -------------
%   myFiles = fullfile(matlabroot, 'examples', 'matlab', '*.bin');
%   ds = MyDatastore(myFiles);
%   % Call numpartitions to identify number of partitions for this datastore
%   n = numpartitions(ds);
%   % Call partition to partition the datastore and return the partitioned
%   % datastore corresponding to the index 4
%   subds = partition(ds,n,4);
%
%   See also matlab.io.Datastore, mapreduce, matlab.io.datastore.HadoopFileBased.

%   Copyright 2017 The MathWorks, Inc.

    methods(Access = public, Sealed)
        function n = numpartitions(ds, pool)
            %NUMPARTITIONS Return an estimate for a reasonable number of
            %   partitions for the given information.
            %
            %   N = NUMPARTITIONS(DS) returns the default number of
            %   partitions for a given datastore, DS.
            %
            %   N = NUMPARTITIONS(DS, POOL) returns a reasonable number of
            %   partitions to parallelize DS over a parallel pool, POOL.
            %
            %   In the provided default implementation, the minimum of
            %   maxpartitions on the datastore, DS, and thrice the number
            %   of workers available, is returned as the number of partitions, N.
            %
            %   See also matlab.io.datastore.Partitionable, partition,
            %   maxpartitions.
            try
                numWorkers = Inf;
                if nargin >= 2
                    validateattributes(pool, {'parallel.Pool'}, {}, 'numpartitions', 'pool');
                    if ~isempty(pool)
                        numWorkers = pool.NumWorkers;
                    end
                end
            catch ME
                throw(ME);
            end

            try
                maxNumPartitions = maxpartitions(ds);
            catch ME
                if numel(ME.stack) == numel(dbstack)
                    % Error is a problem with the method definition itself.
                    error(message('MATLAB:datastoreio:datastore:malformedDatastoreMethod', ...
                        class(ds), ...
                        'maxpartitions', ...
                        ME.message));
                end
                rethrow(ME);
            end

            if ~matlab.io.datastore.internal.validators.isNumLogical(maxNumPartitions) ...
                    || maxNumPartitions < 0 || mod(maxNumPartitions, 1) ~= 0
                error(message('MATLAB:datastoreio:datastore:invalidMaxpartitionsOutput', ...
                    class(ds), ...
                    'maxpartitions'));
            end

            % We choose 3 * numWorkers for load balancing reasons.
            n = min(double(maxNumPartitions), 3 * numWorkers);
        end
    end

    methods(Access = protected, Abstract)
        %MAXPARTITIONS Return the maximum number of partitions possible for
        % the datastore.
        %
        %   N = MAXPARTITIONS(DS) returns the maximum number of partitions for a
        %   given Datastore, DS.
        %   This is an abstract method and must be implemented by subclasses
        %   inheriting from Partitionable.
        %   If the datastore is based on files and uses a
        %   matlab.io.datastore.DsFileSet object, a good estimate for
        %   maximum number of partitions is provided by the maxpartitions
        %   method of DsFileSet object.
        %
        %   See also matlab.io.datastore.Partitionable, numpartitions,
        %   partition.
        n = maxpartitions(ds);
    end

    methods(Access = public, Abstract)
        %PARTITION Return a partitioned part of the Datastore.
        %
        %   SUBDS = PARTITION(DS,N,INDEX) partitions DS into
        %   N parts and returns the partitioned Datastore, SUBDS,
        %   corresponding to INDEX. An estimate for a reasonable value for
        %   N can be obtained by using the NUMPARTITIONS function.
        %   This is an abstract method and must be implemented by subclasses
        %   inheriting from Partitionable.
        %   If the datastore is based on files and uses a
        %   matlab.io.datastore.DsFileSet object as a property, a good
        %   candidate for this implementation is as below:
        %
        %     subds = copy(ds);
        %     subds.DsFileSet = partition(ds.DsFileSet, n, index);
        %     reset(subds.DsFileSet);
        %     reset(subds);
        %
        %   See also matlab.io.datastore.Partitionable, numpartitions,
        %   maxpartitions.
        subds = partition(ds,n,index);
    end
end
