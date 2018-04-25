classdef MatKVFileSplitter < matlab.io.datastore.splitter.FileBasedSplitter
%MATKVFILESPLITTER Splitter for splitting key value mat files.
%    A splitter that creates splits from all the mat files provided that
%    contain key value pairs. All the mat files must have two variables,
%    'Key' and 'Value'. 'Key' can either be a cell array of strings or a
%    numeric vector of length equal to number of keys. 'Values' are always
%    a cell array of length equal to number of keys.
%
% See also - matlab.io.datastore.KeyValueDatastore

%   Copyright 2015-2016 The MathWorks, Inc.

    properties (Constant, Access = private)
        % Default key value split size, one split can have at most.
        DEFAULT_KV_SPLIT_SIZE = 1000;
        % Allowed key and value variable names in the MAT-Files provided.
        MAT_FILE_KEY_VALUE_VARIABLES = {'Key', 'Value'};
        % From 15a we added a SchemaVersion variable to the MAT-Files
        MAT_FILE_THREE_VARIABLES = {'Key', 'SchemaVersion', 'Value'};
        % Allowed value variable names in the MAT-Files provided.
        % This is to support TallDatastore with only Values.
        MAT_FILE_VALUE_VARIABLES = {'SchemaVersion', 'Value'};
        % Filename suffix for TallDatastore MAT-files
        SNAPSHOT_SUFFIX_STR = 'snapshot';
        HEX_PREFIX_STR = '0x';
    end

    methods (Static)
        function splitter = create(fileInfo, kvsplitsize)
            narginchk(1,2);
            files = fileInfo.Files;
            if ischar(files)
                files = { files };
            end
            splits = [];
            import matlab.io.datastore.splitter.MatKVFileSplitter;
            if nargin == 1
                kvsplitsize = MatKVFileSplitter.DEFAULT_KV_SPLIT_SIZE;
            end
            splitter = MatKVFileSplitter;
            splitter.SplitSizeLimit = kvsplitsize;
            if ~isempty(files)
                if ~iscellstr(files)
                    error(message('MATLAB:datastoreio:filesplitter:invalidFilesInput'));
                end
                [splits, fileInfo] = getSplitsFromInfo(fileInfo, kvsplitsize);
            end
            splitter.FileSizes = fileInfo.FileSizes;
            splitter.Files = fileInfo.Files;
            splitter.Splits = splits;
        end

        function splitter = createFromSplits(splits)
            % Create a splitter from given splits
            import matlab.io.datastore.splitter.MatKVFileSplitter;
            splitter = MatKVFileSplitter;
            splitter.SplitSizeLimit = MatKVFileSplitter.DEFAULT_KV_SPLIT_SIZE;
            splitter.Files = {};
            splitter.FileSizes = [];
            if ~isempty(splits)
                if ~isstruct(splits) || ...
                   ~isempty(setdiff({'Filename','Offset','Size','FileIndex', 'SchemaAvailable', 'ValuesOnly'},fieldnames(splits)))
                    error(message('MATLAB:datastoreio:filesplitter:invalidSplits'));
                end
                % use unique file indices to set the new FileIndex'es
                [~, idxs, ia] = unique([splits.FileIndex], 'stable');
                splitter.Files = {splits(idxs).Filename}';
                splitter.FileSizes = [splits(idxs).Size];
                for ii = 1:numel(splits)
                    splits(ii).FileIndex = ia(ii);
                end
                splitter.Splits = splits;
            end
        end
    end

    methods (Static, Hidden)
        function tf = verifyKeysValues(fileInfo, valuesOnly)
            % Check if all the mat files have MAT_FILE_NUM_VARIABLES number of
            % variables, variable names equal to MAT_FILE_KEY_VALUE_VARIABLES, and
            % they are column vectors of same length.
            import matlab.io.datastore.splitter.MatKVFileSplitter;
            if valuesOnly
                tf = MatKVFileSplitter.verifyValuesOnly(fileInfo);
                return;
            end
            numVars = numel(fileInfo);
            tf = false;
            switch numVars
                % Number of variables must be 2 or 3
                % Variable names must be MAT_FILE_KEY_VALUE_VARIABLES
                % or MAT_FILE_THREE_VARIABLES
                case 2
                    tf = all(strcmp({fileInfo.name}, MatKVFileSplitter.MAT_FILE_KEY_VALUE_VARIABLES));
                case 3
                    tf = all(strcmp({fileInfo.name}, MatKVFileSplitter.MAT_FILE_THREE_VARIABLES));
                otherwise
                   return; 
            end
            if ~tf
                return;
            end
            ks = fileInfo(1).size;
            vs = fileInfo(numVars).size;
            % Variables must be column vectors of same length.
            tf = numel(ks) == 2  && numel(vs) == 2 && ...
                    ks(2) == 1 && vs(2) == 1 && ks(1) == vs(1);
        end

        % Verify the Value shape in the MAT-file 
        function tf = verifyValuesOnly(fileInfo)
            import matlab.io.datastore.splitter.MatKVFileSplitter;
            numVars = numel(fileInfo);
            tf = false;
            if ~all(strcmp({fileInfo.name}, MatKVFileSplitter.MAT_FILE_VALUE_VARIABLES))
                return;
            end
            vs = fileInfo(numVars).size;
            % Variable Value must be a column vector.
            tf = numel(vs) == 2 && vs(2) == 1;
        end

        % Check if a MAT-file is supported
        % matFileInfo is a struct from whos function 
        function [tf, matFileInfo] = isMatSupported(filename, valuesOnly)
            % Use whos to introspect size and variable names in a mat file.
            % Constructing a matfile object to find the sizes and the variable
            % names would take double the time, compared to whos.
            import matlab.io.datastore.splitter.MatKVFileSplitter;
            tf = false;
            matFileInfo = [];
            warningId = 'MATLAB:whos:UnableToRead';
            warning('off', warningId);
            c = onCleanup(@() warning('on', warningId));
            try
                matFileInfo = whos('-file', filename);
                if ~isempty(matFileInfo)
                    tf = MatKVFileSplitter.verifyKeysValues(matFileInfo, valuesOnly);
                end
            catch e
                % swallow the error and return
            end
        end

        % filter MAT-files that are supported
        % FileInfo contains information needed to create splits
        function [fileInfo, tf, idx] = filterMatFiles(files, valuesOnly)
            import matlab.io.datastore.splitter.MatKVFileSplitter;
            fileInfo = [];
            tf = true;
            idx = -1;
            numFiles = numel(files);
            isMat = false(numFiles, 1);
            fileSizes = zeros(numFiles, 1);
            schemaAvailable = false(numFiles, 1);
            valuesOnlyAvailable = false(numFiles, 1);
            for ii = 1:numFiles
                if valuesOnly
                    info = iParseValuesOnlyFilename(files{ii});
                else
                    [~, info] = MatKVFileSplitter.isMatSupported(files{ii}, valuesOnly);
                end
                if ~isempty(info)
                    isMat(ii) = true;
                    if valuesOnly
                        schemaAvailable(ii) = true;
                        valuesOnlyAvailable(ii) = true;
                        % Get the Value size
                        fileSizes(ii) = info.size;
                    else
                        % Get the Key size
                        fileSizes(ii) = info(1).size(1);
                        if numel(info) == 3
                            % SchemaVersion is available from 15a
                            schemaAvailable(ii) = true;
                        end
                    end
                elseif nargout > 1
                    % No need to fillout the fileInfo
                    % Return with index of the file that's not supported
                    tf = false;
                    idx = ii;
                    return;
                end
            end
            fileInfo.Files = files(isMat);
            fileInfo.FileSizes = fileSizes(isMat);
            fileInfo.SchemaAvailable = schemaAvailable(isMat);
            fileInfo.ValuesOnlyAvailable= valuesOnlyAvailable(isMat);
        end
    end

    properties (GetAccess = public, SetAccess = private)
        % Mat Files containing key-value pairs.
        Files;
    end

    properties
        % Maximum size of each split.
        SplitSizeLimit;
        % Sizes of all files
        FileSizes;
        % KeyValueLimit for SplitReaders
        KeyValueLimit;
    end

    methods (Hidden)

        function setFilesOnSplits(splitter, files)
            t = struct2table(splitter.Splits);
            t.Filename = files;
            splitter.Splits = table2struct(t);
            splitter.Files = files;
        end

        function data = readAllSplits(splitter)
            % Read all of the data from all the splits
            % This uses ValuesOnly boolean from the split information
            % to decide if only Values to be read from MAT-Files or not.
            warning('off', 'MATLAB:MatFile:OlderFormat');
            c = onCleanup(@()warning('on', 'MATLAB:MatFile:OlderFormat'));
            data = table;
            if isempty(splitter.Files) || isempty(splitter.Splits)
                return;
            end
            numSplits = numel(splitter.Splits);
            datasize = 0;
            splitSizeLimit = splitter.SplitSizeLimit;

            datacumsizes = zeros(1, numSplits);
            for ii = 1:numSplits
                split = splitter.Splits(ii);
                splitSize = splitSizeLimit;
                endSize = split.Size - split.Offset + 1;
                if endSize < splitSize
                    splitSize = endSize;
                end
                datasize = datasize + splitSize;
                if ii == 1
                    datacumsizes(ii) = splitSize;
                else
                    datacumsizes(ii) = datacumsizes(ii-1) + splitSize;
                end
            end
            import matlab.io.datastore.splitreader.MatKVFileSplitReader;
            import matlab.io.datastore.splitter.MatKVFileSplitter;
            rdr = MatKVFileSplitReader(numel(splitter.Files), splitSizeLimit, splitSizeLimit);
            rdr.Split = splitter.Splits(1);
            valuesOnly = rdr.Split.ValuesOnly;
            reset(rdr);
            [Key, Value] = readFullSplit(rdr, datacumsizes(1));
            if ~valuesOnly
                % Keys are not needed if ValuesOnly, for example in case of TallDatastore
                if iscell(Key)
                    data.Key = cell(datasize, 1);
                elseif isnumeric(Key)
                    data.Key = zeros(datasize, 1, 'like', Key);
                end
            end
            if iscell(Value)
                data.Value = cell(datasize, 1);
            elseif isnumeric(Value)
                data.Value = zeros(datasize, 1, 'like', Value);
            end
            keyClass = class(Key);
            valueClass = class(Value);
            if ~valuesOnly
                % Keys are not needed if ValuesOnly, for example in case of TallDatastore
                data.Key(1:datacumsizes(1), 1) = Key;
            end
            data.Value(1:datacumsizes(1), 1) = Value;
            for ii = 2:numSplits
                splitSize = datacumsizes(ii) - datacumsizes(ii-1);
                rdr.Split = splitter.Splits(ii);
                reset(rdr);
                [Key, Value] = readFullSplit(rdr, splitSize);
                stidx = datacumsizes(ii-1) + 1;
                if ~valuesOnly
                    % Keys are not needed if ValuesOnly, for example in case of TallDatastore
                    try
                        data.Key(stidx:datacumsizes(ii), 1) = Key;
                    catch e
                        MatKVFileSplitter.invalidKeyValueError(keyClass, class(Key),...
                            splitter.Splits(1).Filename, splitter.Splits(ii).Filename, e, true);
                    end
                end
                try
                    data.Value(stidx:datacumsizes(ii), 1) = Value;
                catch e
                    MatKVFileSplitter.invalidKeyValueError(valueClass, class(Value),...
                        splitter.Splits(1).Filename, splitter.Splits(ii).Filename, e, false);
                end
            end
        end

        % set all splits to have the SchemaAvailable field to the
        % given boolean.
        function setSchemaAvailable(splitter, tf)
            [splitter.Splits.SchemaAvailable] = deal(tf);
        end

        % set all splits to have the ValuesOnly field to the
        % given boolean.
        function setSplitsWithValuesOnly(splitter, tf)
            [splitter.Splits.ValuesOnly] = deal(tf);
        end

        % A MATKVFileSplitter uses chunked splits.
        function tf = isFullFileSplitter(~)
            tf = false;
        end

        %isSplitsOverAllOfFiles Returns true if a splitter splits is guaranteed to cover all of Files property.
        % A FileBasedSplitter that has been partitioned cannot guarantee that
        % the contained collection of splits is equivalent to creating a new
        % splitter from the Files property. This method allows clients of
        % FileBasedSplitter to guard against this.
        function tf = isSplitsOverAllOfFiles(splitter)
            tf = true;
            splits = splitter.Splits;
            if numel(splits) == 0
                return;
            end
            [~, ia, ic] = unique([splits.FileIndex], 'stable');
            % Accumulate splitSizes for each unique file index
            fileSizes = accumarray(ic, ones(size(ic)) * splitter.SplitSizeLimit);
            for ii = 1:numel(fileSizes)
                if fileSizes(ii) < splits(ia(ii)).Size
                    tf = false;
                    return;
                end
            end
        end

        % Return a reader for the ii-th split.
        function rdr = createReader(splitter, ii)
            rdr = matlab.io.datastore.splitreader.MatKVFileSplitReader(...
                    numel(splitter.Files), splitter.KeyValueLimit, splitter.SplitSizeLimit);
            rdr.Split = splitter.Splits(ii);
        end

        % Create Splitter from existing Splits
        %
        % Splits passed as input must be of identical in structure to the
        % splits used by this Spltiter class.
        function splitterCopy = createCopyWithSplits(splitter, splits)
            splitterCopy = splitter.createFromSplits(splits);
            splitterCopy.KeyValueLimit = splitter.KeyValueLimit;
        end
    end
    methods (Static, Access = private)
        function invalidKeyValueError(c1, c2, f1, f2, e, keyError)
            if strcmp(e.identifier, 'MATLAB:invalidConversion')
                msgid = 'MATLAB:datastoreio:keyvaluedatastore:invalidKeyConversion';
                if ~keyError
                    msgid = 'MATLAB:datastoreio:keyvaluedatastore:invalidValueConversion';
                end
                msg = message(msgid, c1, c2, f1, f2);
                throw(MException(msg));
            end
            throw(e);
        end
    end
end

% Using the fileinfo generated during initializaiton create splits
function [splits, fileInfo] = getSplitsFromInfo(fileInfo, kvsplitsize)
    numFiles = numel(fileInfo.Files);
    splits = cell(numFiles, 1);
    for ii = 1:numFiles
        numkv = fileInfo.FileSizes(ii);
        offsets = 1:kvsplitsize:numkv;
        % No need to check if nsplits == 0, since empty files are filtered out
        nsplits = numel(offsets);
        % Use FileIndex in MatKVFileSplitReader to cache mat
        % file objects, as they are expensive proportional to
        % the number of key value pairs in the mat file.
        filenames = repmat(fileInfo.Files(ii), 1, nsplits);
        sizes = repmat(numkv, 1, nsplits);
        fileIdcs = repmat(ii, 1, nsplits);
        schAvails = repmat(fileInfo.SchemaAvailable(ii), 1, nsplits);
        valuesOnly = repmat(fileInfo.ValuesOnlyAvailable(ii), 1, nsplits);
        splits{ii} = struct('Filename', filenames, 'Size', num2cell(sizes), ...
            'Offset', num2cell(offsets), 'FileIndex', num2cell(fileIdcs), ...
            'SchemaAvailable', num2cell(schAvails), 'ValuesOnly', num2cell(valuesOnly));
    end
    splits = [splits{:}];
end

% Parse the filename when ValuesOnly is true - for TallDatastore.
% For example:
%    From tall/write, filename could be of the form 'array_r10_1_snapshot_8A'
%    Here '8A' represents the number of values in the MAT-file in hex form.
%    - outInfo is a struct with the above number, when the filename matches the pattern
%    - outInfo is a struct from whos, when the filename does not match the above pattern.
function outInfo = iParseValuesOnlyFilename(filename)
    import matlab.io.datastore.splitter.MatKVFileSplitter;
    [~,name,ext] = fileparts(filename);
    pattern = ['\w*_',...
              MatKVFileSplitter.SNAPSHOT_SUFFIX_STR,'_',...
              MatKVFileSplitter.HEX_PREFIX_STR,...
              '(\w*)$'];
    numKV = regexp(name, pattern, 'tokens', 'once');
    outInfo = [];
    if strcmp(ext, '.mat') && ~isempty(numKV) && ~isempty(numKV{1})
        try
            % convert the hex number of values to decimal
            outInfo.size = hex2dec(numKV{1});
        catch
            % swallow and use legacy support check
        end
    end
    if isempty(outInfo)
        % Legacy MAT-file support check:
        % Use whos to find if the MAT-file is supported.
        % We reach here if the filenames are changed manually
        % or MAT-file is constructed manually
        % or if the file is not from tall/write 
        [~, info] = MatKVFileSplitter.isMatSupported(filename, true);
        if ~isempty(info)
            outInfo.size = info(2).size(1);
        end
    end
end
