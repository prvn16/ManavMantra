classdef MatKVFileSplitter < matlab.io.datastore.internal.FileBasedSplitter
%MATKVFILESPLITTER Splitter for splitting key value mat files.
%    A splitter that creates splits from all the mat files provided that
%    contain key value pairs. All the mat files must have two variables,
%    'Key' and 'Value'. 'Key' can either be a cell array of strings or a
%    numeric vector of length equal to number of keys. 'Values' are always
%    a cell array of length equal to number of keys.
%
% See also - matlab.io.datastore.KeyValueDatastore

%   Copyright 2014-2016 The MathWorks, Inc.

    properties (Constant, Access = private)
        % Default key value split size, one split can have at most.
        DEFAULT_KV_SPLIT_SIZE = 1000;
        % Allowed key and value variable names in the mat files provided.
        MAT_FILE_KEY_VALUE_VARIABLES = {'Key', 'Value'};
        MAT_FILE_THREE_VARIABLES = {'Key', 'SchemaVersion', 'Value'};
    end
    
    properties (Access = private)
        CreatedFromFiles = true; % A property that represents if this splitter
                                 % was created from a list of files.
    end

    methods (Static, Access = public)
        function splitter = create(files, userPassedFileType, kvsplitsize)
            narginchk(2,3);
            if ischar(files)
                files = { files };
            end
            splits = [];
            import matlab.io.datastore.internal.MatKVFileSplitter;
            if nargin < 3
                kvsplitsize = MatKVFileSplitter.DEFAULT_KV_SPLIT_SIZE;
            end
            splitter = MatKVFileSplitter;
            splitter.SplitSizeLimit = kvsplitsize;
            if ~isempty(files)
                if ~iscellstr(files)
                    error(message('MATLAB:datastoreio:filesplitter:invalidFilesInput'));
                end
                % convert all file scheme IRIs to local paths
                [~, isLocal] = matlab.io.datastore.internal.localPathToIRI(files);
                if ~all(isLocal)
                    error(message('MATLAB:datastoreio:pathlookup:fileNotFound', files{find(~isLocal, 1)}));
                end
                files = matlab.io.datastore.internal.pathLookup(files);
                if ~isempty(files)
                    % Use FileIndex in MatKVFileSplitReader to cache mat file
                    % objects, as they are expensive proportional to the number
                    % of key value pairs in the mat file.
                    fileIdcs = 1:1:numel(files);
                    splits = arrayfun(...
                        @(file, fileIdx)getSplitsFromMatKVFile(file{1}, ...
                        kvsplitsize, fileIdx, splitter, userPassedFileType),...
                        files, fileIdcs, 'UniformOutput', false);
                    splits = [splits{:}];
                end
            end
            splitter.Files = files;
            splitter.Splits = splits;
        end
        function splitter = createFromSplits(splits)
            % Create a splitter from given splits
            import matlab.io.datastore.internal.MatKVFileSplitter;
            splitter = MatKVFileSplitter;
            splitter.SplitSizeLimit = MatKVFileSplitter.DEFAULT_KV_SPLIT_SIZE;
            splitter.Files = {};
            splitter.FileSizes = [];
            if ~isempty(splits)
                if ~isstruct(splits) || ...
                   ~isempty(setdiff({'File','Offset','Size','FileIndex', 'SchemaAvailable'},fieldnames(splits)))
                    error(message('MATLAB:datastoreio:filesplitter:invalidSplits'));
                end
                % use only the unique filepaths
                [~, idxs, ia] = unique([splits.FileIndex], 'stable');                
                splitter.Files = {splits(idxs).File};
                splitter.FileSizes = [splits(idxs).Size];
                for ii = 1:numel(splits)
                    splits(ii).FileIndex = ia(ii);
                end
                splitter.Splits = splits;
            end
            splitter.CreatedFromFiles = false;
        end
    end

    methods (Static, Hidden, Access = public)
        function verifyKeysValues(fileInfo, filename)
            % Check if all the mat files have MAT_FILE_NUM_VARIABLES number of
            % variables, variable names equal to MAT_FILE_KEY_VALUE_VARIABLES, and
            % they are column vectors of same length.
            import matlab.io.datastore.internal.MatKVFileSplitter;
            numVars = numel(fileInfo);
            vn = false;
            switch numVars
                % Number of variables must be 2 or 3
                % Variable names must be MAT_FILE_KEY_VALUE_VARIABLES
                % or MAT_FILE_THREE_VARIABLES
                case 2
                    vn = all(strcmp({fileInfo.name}, MatKVFileSplitter.MAT_FILE_KEY_VALUE_VARIABLES));
                case 3
                    vn = all(strcmp({fileInfo.name}, MatKVFileSplitter.MAT_FILE_THREE_VARIABLES));
                otherwise
                    error(message('MATLAB:datastoreio:keyvaluedatastore:unsupportedFiles', filename));
            end
            if ~vn
                error(message('MATLAB:datastoreio:keyvaluedatastore:unsupportedFiles', filename));
            end
            ks = fileInfo(1).size;
            vs = fileInfo(numVars).size;
            % Variables must be column vectors of same length.
            ishape = numel(ks) == 2  && numel(vs) == 2 && ...
                    ks(2) == 1 && vs(2) == 1 && ks(1) == vs(1);
            if ~ishape
                error(message('MATLAB:datastoreio:keyvaluedatastore:unsupportedFiles', filename));
            end
        end

        function [tf, matFileInfo] = isMatSupported(filename)
            import matlab.io.datastore.internal.MatKVFileSplitter;
            tf = true;
            matFileInfo = [];
            try
                matFileInfo = whos('-file', filename);
            catch e
                tf = false;
                if ~any(strcmp(e.identifier, {'MATLAB:whos:notValidMatFile', ...
                        'MATLAB:whos:fileIsNotThere'}))
                    reThrow(e);
                end
            end
            if ~isempty(matFileInfo)
                MatKVFileSplitter.verifyKeysValues(matFileInfo, filename);
            end
        end
    end

    properties (Access = public)
        % Mat Files containing key-value pairs.
        Files;
        % Struct Array containing splits for the mat files.
        Splits;
        % Maximum size of each split.
        SplitSizeLimit;
        % Sizes of all files
        FileSizes;
    end

    methods (Access = public, Hidden)
        function data = readAllSplits(splitter)
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
            import matlab.io.datastore.internal.MatKVFileSplitReader;
            rdr = MatKVFileSplitReader(numel(splitter.Files), splitSizeLimit, splitSizeLimit);
            rdr.Split = splitter.Splits(1);
            reset(rdr);
            [Key, Value] = readFullSplit(rdr, datacumsizes(1));
            if iscell(Key)
                data.Key = cell(datasize, 1);
            elseif isnumeric(Key)
                data.Key = zeros(datasize, 1, 'like', Key);
            end
            if iscell(Value)
                data.Value = cell(datasize, 1);
            elseif isnumeric(Value)
                data.Value = zeros(datasize, 1, 'like', Value);
            end
            keyClass = class(Key);
            valueClass = class(Value);
            data.Key(1:datacumsizes(1), 1) = Key;
            data.Value(1:datacumsizes(1), 1) = Value;
            for ii = 2:numSplits
                splitSize = datacumsizes(ii) - datacumsizes(ii-1);
                rdr.Split = splitter.Splits(ii);
                reset(rdr);
                [Key, Value] = readFullSplit(rdr, splitSize);
                stidx = datacumsizes(ii-1) + 1;
                try
                    data.Key(stidx:datacumsizes(ii), 1) = Key;
                catch e
                    import matlab.io.datastore.internal.MatKVFileSplitter;
                    MatKVFileSplitter.invalidKeyValueError(keyClass, class(Key),...
                        splitter.Splits(1).File, splitter.Splits(ii).File, e, true);
                end
                try
                    data.Value(stidx:datacumsizes(ii), 1) = Value;
                catch e
                    import matlab.io.datastore.internal.MatKVFileSplitter;
                    MatKVFileSplitter.invalidKeyValueError(valueClass, class(Value),...
                        splitter.Splits(1).File, splitter.Splits(ii).File, e, false);
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

    end
    methods (Static, Hidden, Access = private)
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
    
    methods (Access = 'public')
        % A MATKVFileSplitter always used chunked splits.
        function tf = isFullFileSplitter(~)
            tf = false;
        end
        
        %isSplitsOverAllOfFiles Returns true if a splitter splits is guaranteed to cover all of Files property.
        % A FileSplitter that has been partitioned cannot guarantee that
        % the contained collection of splits is equivalent to creating a new
        % splitter from the Files property. This method allows clients of
        % FileSplitter to guard against this.
        function tf = isSplitsOverAllOfFiles(splitter)
            tf = splitter.CreatedFromFiles;
        end
    end
end

function splits = getSplitsFromMatKVFile(file, kvsplitsize, fileIdx, splitter, userPassedFileType)
    % Use whos to introspect size and variable names in a mat file.
    % Constructing a matfile object to find the sizes and the variable
    % names would take double the time, compared to whos.
    import matlab.io.datastore.internal.MatKVFileSplitter;
    [tf, fileInfo] = MatKVFileSplitter.isMatSupported(file);
    if ~tf
        if userPassedFileType
            import matlab.io.datastore.KeyValueDatastore;
            KeyValueDatastore.unExpectedFileTypeError('mat', file);
        else
            error(message('MATLAB:datastoreio:keyvaluedatastore:unsupportedFiles', file));
        end
    end
    numkv = fileInfo(1).size(1);
    splitter.FileSizes(fileIdx) = numkv;
    offsets = 1:kvsplitsize:numkv;
    nsplits = numel(offsets);
    if nsplits == 0
        splits = [];
        return;
    end
    filenames = repmat({file}, 1, nsplits);
    sizes = repmat(numkv, 1, nsplits);
    fileIdcs = repmat(fileIdx, 1, nsplits);
    schemaAvailable = false;
    if numel(fileInfo) == 3
        schemaAvailable = true;
    end
    schAvails = repmat(schemaAvailable, 1, nsplits);
    splits = struct('File', filenames, 'Size', num2cell(sizes), ...
        'Offset', num2cell(offsets), 'FileIndex', num2cell(fileIdcs), ...
        'SchemaAvailable', num2cell(schAvails));
end
