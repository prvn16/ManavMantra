classdef (Hidden = true, AllowedSubclasses = {?matlab.io.datastore.TabularTextDatastore, ?matlab.io.datastore.KeyValueDatastore, ?matlab.io.datastore.CustomReadDatastore, ?matlab.io.datastore.SpreadsheetDatastore, ?matlab.io.datastore.MatSeqDatastore, ?matlab.io.datastore.MDFDatastore}) ...
        FileBasedDatastore < matlab.io.datastore.internal.HandleUnwantedHideable &...
        matlab.io.datastore.SplittableDatastore

%FileBasedDatastore  Super class for splittable file based datastores. 
%   This class inherits from SplittableDatastore and is the super class for
%   all file based datastores. It requires all its subclasses to implement
%   the property ReadSize which control the size of the data returned by
%   the read method. It also provides default implementations for hasdata,
%   reset and loadobj methods.

%   Copyright 2014-2017 The MathWorks, Inc.

    properties (Transient, Access = 'private')
        %ISVALIDDATASTORE Boolean to indicate a valid datastore.
        %   IsValidDatastore indicates if a datastore is valid to read
        %   from. A datastore becomes invalid once it has been loaded from
        %   a mat file. This property is used to make the datastore valid
        %   by setting the property in the public methods (hasdata)
        IsValidDatastore = true;
    end
    
    properties (Abstract)
        %FILES included in datastore.
        %   This class requires access to the Files property, however the
        %   actual definition will come from children of this class.
        Files;
    end

    methods (Access = protected)
        function tf = isEmptyFiles(ds)
            tf = ds.Splitter.NumSplits == 0;
        end

        function setTransformedFiles(ds, files)
            ds.Splitter.setFilesOnSplits(files);
        end

        function files = getFilesForTransform(ds)
            files = ds.Files;
        end
        function [diffIndexes, currIndexes, files, fileSizes, diffPaths] = setNewFilesAndFileSizes(ds, files)
            import matlab.io.datastore.internal.validators.validatePaths;
            import matlab.io.datastore.internal.indexOfFirstFolderOrWildCard;
            if ischar(files)
                files = {files};
            end
            % ensure the given paths are valid strings or cell array of strings
            files = validatePaths(files);

            files = files(:);
            % get the appended or modified file list

            sfiles = string(files);
            sdsFiles = string(ds.Files);
            [newIndexes, currIndexes] = ismember(sfiles, sdsFiles);

            diffIndexes = ~newIndexes;
            % currIndexes is a double array. Get indexes of current Files property.
            fileSizes = zeros(size(files));
            currIndexes = currIndexes(currIndexes ~= 0);
            if ~isempty(currIndexes)
                % There's definitely splits for current files
                fileSizes(newIndexes) = ds.Splitter.getFileSizes(currIndexes);
            end
            diffPaths = files(diffIndexes);
            if ~isempty(diffPaths)
                % get the index of the first string which is a folder or
                % contains a wildcard
                idx = indexOfFirstFolderOrWildCard(diffPaths);

                % error for folder or wild card inputs
                if (-1 ~= idx)
                    error(message('MATLAB:datastoreio:filebaseddatastore:nonFilePaths', diffPaths{idx}));
                end
                % resolve only the modified paths
                [diffPaths, diffFileSizes] = matlab.io.datastore.internal.pathLookup(diffPaths, false);
                fileSizes(diffIndexes) = diffFileSizes;
            end
        end

    end
        
    methods        
        function tf = hasdata(ds)
            %HASDATA Returns true if there is more data in the Datastore.
            %   TF = hasdata(DS) returns true if there is more data in the
            %   Datastore, TDS, and false otherwise. read(DS) issues an
            %   error when hasdata(DS) returns false.
            %
            %   Example:
            %   --------
            %      % Create a TabularTextDatastore
            %      tabds = tabularTextDatastore('airlinesmall.csv')
            %      % Handle erroneous data
            %      tabds.TreatAsMissing = 'NA'
            %      tabds.MissingValue = 0;
            %      % We are only interested in the Arrival Delay data
            %      tabds.SelectedVariableNames = 'ArrDelay'
            %      % Preview the first 8 rows of the data as a table
            %      tab8 = preview(tabds)
            %      % Sum the Arrival Delays
            %      sumAD = 0;
            %      while hasdata(tabds)
            %         tab = read(tabds);
            %         sumAD = sumAD + sum(tab.ArrDelay);
            %      end
            %      sumAD
            %
            %     See also matlab.io.datastore.TabularTextDatastore, read, readall, preview, reset.
        
            try
                % reset the datastore if invalid
                %
                % if reset() throws an error, keep the datastore in an
                % invalid state so that this action is retried.
                if ~ds.IsValidDatastore
                    reset(ds);
                    ds.IsValidDatastore = true;
                end
                
                tf = hasdata@matlab.io.datastore.SplittableDatastore(ds);
            catch ME
                throwAsCaller(ME);
            end
        end
        
        function reset(ds)
        %RESET   Reset to the start of the data.
        %   This method is responsible for setting the state of the
        %   datastore to a valid state before resetting to the start of the
        %   data.
        %
        %   See also READ, READALL, PREVIEW, RESET,
        %   matlab.io.datastore.TabularTextDatastore
        
            try
                reset@matlab.io.datastore.SplittableDatastore(ds);
            catch ME
                throw(ME);
            end
            
            % when reset is called, the datastore needs to be set to a
            % valid state. unnecessary to check if it is false here.
            ds.IsValidDatastore = true;
        end
    end
    
    methods
        function subds = partition(ds, partitionStrategy, index)
            %PARTITION Return a partitioned part of the Datastore.
            %
            %   SUBDS = PARTITION(DS,NUMPARTITIONS,INDEX) partitions DS into
            %   NUMPARTITIONS parts and returns the partitioned DATASTORE,
            %   SUBDS, corresponding to INDEX. An estimate for a reasonable value for the
            %   NUMPARTITIONS input can be obtained by using the NUMPARTITIONS function.
            %
            %   SUBDS = PARTITION(DS,'Files',INDEX) partitions DS by files in the
            %   Files property and returns the partition corresponding to INDEX.
            %
            %   SUBDS = PARTITION(DS,'Files',FILENAME) partitions DS by files and
            %   returns the partition corresponding to FILENAME.
            %
            %   Example:
            %      % A datastore that contains 10 copies of the 'airlinesmall.csv'
            %      % example dataset.
            %      files = repmat({'airlinesmall.csv'},1,10);
            %      ds = tabularTextDatastore(files,'TreatAsMissing','NA','MissingValue',0);
            %      ds.SelectedVariableNames = 'ArrDelay';
            %
            %      % This will parse approximately the first third of the example data.
            %      subds = partition(ds,3,1);
            %
            %      totalSum = 0;
            %      while hasdata(subds)
            %         data = read(subds);
            %         totalSum = totalSum + sum(data.ArrDelay);
            %      end
            %      totalSum
            %
            %   See also matlab.io.datastore.TabularTextDatastore, numpartitions.

            if nargin > 1
                partitionStrategy = convertStringsToChars(partitionStrategy);
            end

            if nargin > 2
                index = convertStringsToChars(index);
            end

            try
                if ~ischar(partitionStrategy) || ~strcmpi(partitionStrategy, 'Files')
                    subds = partition@matlab.io.datastore.SplittableDatastore(ds, partitionStrategy, index);
                    return;
                end

                % Input checking
                validateattributes(index, {'double', 'char'}, {}, 'partition', 'Index');
                if ischar(index)
                    filename = index;
                    validateattributes(filename, {'char'}, {'nonempty', 'row'}, 'partition', 'Filename');

                    index = find(strcmp(ds.Files, filename));
                    if isempty(index)
                        error(message('MATLAB:datastoreio:splittabledatastore:invalidPartitionFile', filename));
                    end

                    if numel(index) > 1
                        error(message('MATLAB:datastoreio:splittabledatastore:ambiguousPartitionFile', filename));
                    end
                else
                    validateattributes(index, {'double'}, {'scalar', 'positive', 'integer'}, 'partition', 'Index');
                    if index > numel(ds.Files)
                        error(message('MATLAB:datastoreio:splittabledatastore:invalidPartitionIndex', index));
                    end
                end

                % The actual partitioning.
                subds = copy(ds);

                % FileIndices of the split always have a 1-1 mapping with the
                % Files contained by the datastore. This is ensured in the
                % createFromSplits method of the splitter. set the splitter and
                % reset.
                splits = ds.Splitter.Splits;
                subds.Splitter = ds.Splitter.createCopyWithSplits(splits([splits.FileIndex]== index));
                reset(subds);
                % avoid reset on the workers since we already reset it above
                subds.IsValidDatastore = true;
            catch ME
                throwAsCaller(ME);
            end
        end
    end
    
    methods (Static, Hidden)
        function outds = loadobj(ds)
        %LOADOBJ controls custom loading from a mat file.
        %   loadobj implementation sets a boolean flag to true to indicate
        %   that a datastore loaded from a mat file is in a invalid state
        %   (does not have a file handle open to the first file). This flag
        %   is used in our pulic methods (specifically hasdata()) to reset
        %   the datastore to make the datastore valid.
        
            ds.IsValidDatastore = false;
            outds = ds;
        end

        function [tf, loc, fileSizes, fileExts] = supportsLocation(loc, nvStruct, defaultExtensions, filterExtensions)
            % This function is responsible for determining whether a given
            % location is supported by a FileBasedDatastore. It also returns a
            % resolved filelist and the corresponding file sizes.

            %imports
            import matlab.io.datastore.internal.validators.validateFileExtensions;
            import matlab.io.datastore.internal.validators.validatePaths;
            import matlab.io.datastore.internal.pathLookup;

            % validate file extensions, include subfolders is validated in
            % pathlookup
            isDefaultExts = validateFileExtensions(nvStruct.FileExtensions, nvStruct.UsingDefaults);

            % setup the allowed extensions
            if isDefaultExts
                allowedExts = defaultExtensions;
            else
                allowedExts = nvStruct.FileExtensions;
            end

            % If IncludeSubfolders is already provided, then we do not want to suggest
            % IncludeSubfolders option when erroring for an empty folder
            noSuggestionInEmptyFolderErr = ~ismember('IncludeSubfolders', nvStruct.UsingDefaults);
            if ~noSuggestionInEmptyFolderErr && isfield(nvStruct, 'ValuesOnly')
                % ValuesOnly exists for MatSeqDatastore and is true only for TallDatastore
                % We do not want to suggest IncludeSubfolders option when erroring for an empty folder
                noSuggestionInEmptyFolderErr = nvStruct.ValuesOnly;
            end
            origFiles = loc;
            % validate and lookup paths
            loc = validatePaths(loc);
            if nargout > 2
                [loc, fileSizes] = pathLookup(loc, nvStruct.IncludeSubfolders, noSuggestionInEmptyFolderErr);
            else
                loc = pathLookup(loc, nvStruct.IncludeSubfolders, noSuggestionInEmptyFolderErr);
            end

            szLoc = size(loc);
            % filter based on extensions
            filterExts = true(szLoc);
            fileExts = cell(szLoc);
            isFiltered = false;
            if nargin < 4 || filterExtensions
                for ii = 1:max(szLoc)
                    [~,~,ext] = fileparts(loc{ii});
                    if ~any(strcmpi(allowedExts, ext))
                        filterExts(ii) = false;
                        isFiltered = true;
                    end
                    fileExts{ii} = ext;
                end
                loc = loc(filterExts);
            end
            tf = true;
            switch nargout
                case 1
                    if isempty(loc) || isFiltered
                        % mixed types are not supported during construction
                        tf = false;
                    end
                case 3
                    fileSizes = fileSizes(filterExts);
                case 4
                    fileSizes = fileSizes(filterExts);
                    fileExts = fileExts(filterExts);
            end
            if isempty(loc) && ~isempty(origFiles)
                % if input files are non-empty but Files resolved are empty,
                % we need to error - we don't want to generate an empty datastore
                if ~ismember('FileExtensions', nvStruct.UsingDefaults)
                    % If FileExtensions is already provided, then none of the files
                    % contain the specified file extensions.
                    givenExts = nvStruct.FileExtensions;
                    if iscell(givenExts)
                        givenExts = strjoin(givenExts, ',');
                    end
                    error(message('MATLAB:datastoreio:filebaseddatastore:fileExtensionsNotPresent',  givenExts));
                end
                error(message('MATLAB:datastoreio:filebaseddatastore:allNonstandardExtensions'));
            end
        end
    end
end
