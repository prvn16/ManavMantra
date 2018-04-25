classdef (Sealed) CompressedFileSet  < matlab.io.datastore.internal.fileset.ResolvedFileSet & ...
        matlab.io.datastore.mixin.CrossPlatformFileRoots

%COMPRESSEDFILESET A memory efficient compressed FileSet for collecting files.
%
%   See also datastore,
%            matlab.io.datastore.internal.fileset.InMemoryFileSet,
%            matlab.io.datastore.Partitionable.

%   Copyright 2017 The MathWorks, Inc.

    properties (NonCopyable, Access = private)
        %INTERNALPATHS An internal object to store compressed paths.
        InternalPaths
    end

    properties (Access = private)
        %ORIGINALFILESEP The filesep used to split file paths needs to be persistent.
        OriginalFileSep
        %SHUFFLEDINDICES Indices corresponding to a shuffle that happenend on the files.
        % We store the shuffled indices here and the internal paths object stores the files
        % in the order they were added.
        ShuffledIndices
        %FILENAMESFORTRANSFORM File names to be used during cross platform file
        % roots transformation.
        FileNamesForTransform = []
        %SCHEMAVERSION
        SchemaVersion string
    end

    methods (Access = {?matlab.io.datastore.internal.fileset.ResolvedFileSetFactory})
        function fs = CompressedFileSet(nvStruct)
            fs = fs@matlab.io.datastore.internal.fileset.ResolvedFileSet(nvStruct);
            if isequal(nvStruct.Files, {})
                fs.OriginalFileSep = filesep;
                reset(fs);
            else
                setInitialInternalPaths(fs, nvStruct.Files);
            end
            fs.AlternateFileSystemRoots = nvStruct.AlternateFileSystemRoots;
            fs.SchemaVersion = string(version('-release'));
        end
    end

    methods
        function reset(fs)
            reset@matlab.io.datastore.internal.fileset.ResolvedFileSet(fs);
            if fs.NumFiles == 0
                % if resetting results in zero files, then make sure to have a valid
                % internal paths object.
                fs.InternalPaths = iCreateInternalPaths({},'');
            end
        end
    end

    methods (Hidden)
        function tf = isequal(fs1,fs2, varargin)
            %ISEQUAL Compare CompressedFileSet objects

            tf = compareIfEqual(fs1, fs2);
            if ~tf
                return;
            end
            numArgs = numel(varargin);
            for ii = 1:numArgs
                tf = tf && compareIfEqual(fs1, varargin{ii});
                if ~tf
                    return;
                end
            end
        end

        function newCopy = copyWithFileIndices(fs, indices)
            %COPYWITHFILEINDICES This copies the current object using the input indices.
            %   Based on the input indices fileset object creates a copy.
            %   Sets the file sizes first, and sets the internal paths object for specific
            %   indices.
            newCopy = copy(fs);
            newCopy.FileSizes = newCopy.FileSizes(indices);
            setFileIndices(newCopy, indices, fs.InternalPaths);
            reset(newCopy);
        end

        function setFilesAndFileSizes(fs, files, fileSizes)
            %SETFILESANDFILESIZES Set the files and file sizes for the fileset object.
            %   This is useful when creating an empty file set object and setting the
            %   valid folders and files that are already resolved without any need for
            %   file existence or validity.
            [folders,names,exts] = cellfun(@fileparts, files, 'UniformOutput', false);
            listing = strcat(names, exts);
            [ufolders, ~, groupIndices] = unique(folders, 'stable');
            listing = splitapply(@(x){vertcat(x)}, listing, groupIndices);
            files = [ufolders, listing];
            fs.FileSizes = fileSizes;
            setInitialInternalPaths(fs, files);
        end

        function setShuffledIndices(fs, idxes)
            %SETSHUFFLEDINDICES Set the shuffled indices for files and file sizes of the fileset object.
            %   Any subsequent nextfile calls to the fileset object gets the files
            %   using the shuffled indices. This sets the corresponding file sizes to reflect
            %   the new indices.
            setShuffledIndicesOnly(fs, idxes);
            fs.FileSizes = fs.FileSizes(idxes);
        end

        function setDuplicateIndices(fs, duplicateIndices, addedIndices)
            %SETDUPLICATEINDICES Set the duplicate indices for the fileset object.
            %   Any subsequent nextfile calls to the fileset object gets the files
            %   using the already existing indices and duplicate indices.
            if isempty(fs.ShuffledIndices)
                fs.ShuffledIndices = duplicateIndices;
            else
                currIndicesAdded = duplicateIndices(addedIndices);
                fs.ShuffledIndices(addedIndices) = fs.ShuffledIndices(currIndicesAdded);
            end
            fs.FileSizes = fs.FileSizes(duplicateIndices);
        end

        function s = saveobj(fs)
            %SAVEOBJ Specific to CompressedFileSet this saves all to a struct.
            %   Get all the properties using a struct constructor and save the
            %   CompressedFileSet as a shallow copy. This needs to serialize
            %   the internal paths object as well, that will be loaded on loadobj.
            warningId = 'MATLAB:structOnObject';
            onState = warning('off', warningId);
            c = onCleanup(@() warning(onState));

            s = struct(fs);
            s.CompressedFileSet = fs;
            s = rmfield(s, 'InternalPaths');
            [s.StringTree, s.PathTree] = serialize(fs.InternalPaths);
            s.Frequencies = fs.InternalPaths.Frequencies;
        end

        function newCopy = copyAndOrShuffle(fs, indices)
            %COPYANDORSHUFFLE This copies the current object, with or without shuffling.
            %   Based on the inputs fileset object can decide to either copy
            %   and/or shuffle the fileset. If just shuffling is done, then the output
            %   of this function is empty since a copy is not created.
            newCopy = [];
            currIndices = 1:fs.NumFiles;
            [a,b] = ismember(currIndices, indices);
            if any(~a)
                % empty out some files and add duplicates
                % eg. ds.Files(3:4) = ds.Files(5);
                % eg. ds.Files(3:4) = ds.Files(1:2);
                newCopy = copy(fs);
                newCopy.FileSizes = fs.FileSizes(indices);
                % Find the unique indices in the current list of files
                %  -- This is to get the file paths and set the new compressed paths.
                uniqueIndices = indices(b(a));
                setFileIndices(newCopy, uniqueIndices, fs.InternalPaths);
                % For the new list of files, it's just the linear count of unique files.
                b(a) = 1:numel(uniqueIndices);
                % Set any duplicate paths using the numel of unique indices.
                setShuffledIndicesOnly(newCopy, b(indices));
                reset(newCopy);
            else
                % shuffle
                % eg. ds.Files = ds.Files(randperm(numel(ds.Files)));
                % eg. ds.Files = ds.Files;
                setShuffledIndices(fs, indices);
            end
        end
    end

    methods (Static, Hidden)
        function fs = loadobj(s)
            %LOADOBJ Specific to CompressedFileSet that loads all from a struct.
            %   Get all the properties from a struct saved during saveobj.
            %   CompressedFileSet is a shallow copy, so set all the relevant properties.
            %   This needs to deserialize the internal paths object as well,
            %   using the serialized properties saved during saveobj.
            if isstruct(s)
                % objects saved after 17b
                fs = s.CompressedFileSet;
                st = s.StringTree;
                pt = s.PathTree;
                freq = s.Frequencies;
                fs.InternalPaths = matlab.io.datastore.internal.fileset.HuffmanPaths('tree',...
                    st, pt, freq);

                m = meta.class.fromName('matlab.io.datastore.internal.fileset.CompressedFileSet');
                constProps = {m.PropertyList([m.PropertyList.Constant]).Name};
                propsToRemove = [constProps, { ...
                    'CompressedFileSet',...
                    'StringTree','PathTree','Frequencies', ...
                    'SetFromLoadObj'}];

                s = rmfield(s, propsToRemove);
                fields = fieldnames(s);
                c = onCleanup(@()setDefaultsFromLoadObj(fs));
                fs.SetFromLoadObj = true;
                for i = 1:numel(fields)
                    fs.(fields{i}) = s.(fields{i});
                end
                replaceUNCPaths(fs);
            else
                fs = s;
                if ~isprop(s, 'SchemaVersion') || isempty(s.SchemaVersion)
                    % objects saved in 17b. SchemaVersion introduced in 18a.
                    setInternalPathsFrom17b(fs);
                end
            end
        end
    end

    methods (Access = private)

        function setInternalPathsFrom17b(fs)
            files = cell(fs.NumFiles, 2);
            i = 1;
            reset(fs.InternalPaths);
            % Get all the paths and recreate the internal paths object.
            % Objects from 17b do not have random access.
            while hasNextPath(fs.InternalPaths)
                pth = getNextPath(fs.InternalPaths);
                files(i, 1) = {pth(1:end-1)};
                files(i, 2) = {pth(end)};
                i = i + 1;
            end
            if i == 1
                fs.InternalPaths = iCreateInternalPaths({}, '');
            else
                fs.InternalPaths = iCreateInternalPaths(files, fs.OriginalFileSep, [], false);
            end
        end

        function setInitialInternalPaths(fs, files)
            fs.OriginalFileSep = iFindCorrectFileSep(files);
            % Store an internal compressed paths object.
            fs.InternalPaths = iCreateInternalPaths(files, fs.OriginalFileSep);
            reset(fs);
        end

        function setShuffledIndicesOnly(fs, idxes)
            %SETSHUFFLEDIINDICESONLY Set the shuffled indices for the files of the fileset object.
            %   Any subsequent nextfile calls to the fileset object gets the files
            %   using the shuffled indices.
            if isempty(fs.ShuffledIndices)
                fs.ShuffledIndices = idxes;
            else
                fs.ShuffledIndices = fs.ShuffledIndices(idxes);
            end
        end

        function setDefaultsFromLoadObj(fs)
            defaultSetFromLoadObj(fs);
            fs.FileNamesForTransform = [];
        end

        function tf = compareIfEqual(fs1, fs2)
            warningId = 'MATLAB:structOnObject';
            onState = warning('off', warningId);
            c = onCleanup(@() warning(onState));

            s1 = struct(fs1);
            s2 = struct(fs2);
            ip1 = s1.InternalPaths;
            ip2 = s2.InternalPaths;

            s1 = rmfield(s1, 'InternalPaths');
            s2 = rmfield(s2, 'InternalPaths');
            tf = isequal(s1,s2);
            % String tree and Frequencies are created as per the
            % tree creation in CompressedPaths. They are mapped
            % appropriately but not in a specific order.
            [s1Str,j]= sort(ip1.StringTree);
            s1Freq = ip1.Frequencies(j);
            [s2Str,j]= sort(ip2.StringTree);
            s2Freq = ip2.Frequencies(j);
            tf = tf && isequal(s1Freq, s2Freq) && isequal(s1Str, s2Str);
        end
    end

    methods (Access = protected)

        function tf = isEmptyFiles(fs)
            tf = fs.NumFiles == 0;
        end

        function setTransformedFiles(fs, folders)
            setInitialInternalPaths(fs, [folders, fs.FileNamesForTransform]);
            fs.FileNamesForTransform = [];
        end

        function folders = getFilesForTransform(fs)
            [folders, outfiles] = getPaths(fs.InternalPaths, [1:fs.NumFiles]);
            if ~isempty(folders)
                folders = cellfun(@(x)iJoinSplitPath(x,fs.OriginalFileSep), folders);
            end
            fs.FileNamesForTransform = outfiles;
        end

        function files = getFilesAsCellStr(fs, origIndices)
            %GETFILESASCELLSTR Implementation to obtain a column cell array of files
            % that can be obtained from the fileset object. Use the getPaths method
            % on the internal paths object. Pass the shuffled indices if not empty,
            % with care to send ordered indices to internal paths object.
            if isempty(origIndices)
                files = cell(0,1);
                return;
            end
            numIndexes = numel(origIndices);
            if ~isempty(fs.ShuffledIndices)
                ii = fs.ShuffledIndices(origIndices);
            else
                ii = origIndices;
            end
            if numIndexes > 1
                [ii, ~, i] = unique(ii);
            end
            files = getPaths(fs.InternalPaths, ii, fs.OriginalFileSep);
            if numIndexes > 1
                files = files(i);
            end
        end

        function setFileIndices(fs, indices, internalPaths)
            %SETFILEINDICES A helper to set the indices for files.
            %   This needs to get the paths for the indices as is from
            %   the given internal paths object, and create a new internal
            %   paths with those paths.
            if ~isempty(indices)
                pathIndices = indices;
                if ~isempty(fs.ShuffledIndices)
                    indices = fs.ShuffledIndices(indices);
                    pathIndices = sort(indices);
                    [~, fs.ShuffledIndices] = ismember(indices, pathIndices);
                end
                [folders, outfiles] = getPaths(internalPaths, pathIndices);
                strFreq.String = internalPaths.StringTree;
                strFreq.Frequencies = internalPaths.Frequencies;
                fs.InternalPaths = iCreateInternalPaths([folders, outfiles], fs.OriginalFileSep, strFreq, false);
            end
        end

        function [files, fileSizes] = resolveAll(fs)
            files = getFilesAsCellStr(fs, [1:fs.NumFiles]);
            files = string(files);
            fileSizes = fs.FileSizes;
        end

        function f = resolveNextFile(fs)
            % get the next path from the internal paths object.
            f = getFilesAsCellStr(fs, fs.CurrentFileIndex);
            f = string(f);
        end

        function cpObj = copyElement(fs)
            cpObj = copyElement@matlab.io.datastore.internal.fileset.ResolvedFileSet(fs);
            % create compressed paths based on the already created
            % compressed paths (InternalPaths property).
            cpObj.InternalPaths = matlab.io.datastore.internal.fileset.HuffmanPaths(...
                'copy', fs.InternalPaths);
        end
    end
end

function paths = iCreateInternalPaths(files, originalFileSep, strFreq, needsSplit)
    %ICREATEINTERNALPATHS This function is responsible for creating the compressed paths
    % object. This object is created during construction using the frequencies of each
    % unique character.
    if isempty(files)
        % create an empty paths object for empty partitions
        paths = matlab.io.datastore.internal.fileset.HuffmanPaths;
        freq = [];
        return;
    end
    switch nargin
        case 2
            needsSplit = true;
            strFreq = [];
        case 3
            needsSplit = true;
    end

    if isempty(strFreq)
        paths = matlab.io.datastore.internal.fileset.HuffmanPaths('files', files);
    else
        % Compressed paths can be created by passing tree information or frequency information.
        paths = matlab.io.datastore.internal.fileset.HuffmanPaths('frequencies', ...
            strFreq.String, strFreq.Frequencies);
    end
    if needsSplit
        % This case happens when creating from the recently resolved paths.
        % The other case is when paths is obtained using getPaths and passed
        % down to create a new internal paths object.
        if numel(files(:,1)) == 1
            files{1,1} = iSplitFullFile(files{1,1}, originalFileSep);
        else
            files(:,1) = cellfun(@(x)iSplitFullFile(x, originalFileSep), files(:,1), 'UniformOutput', false);
        end
    end
    paths.addPaths(files(:,1), files(:,2));
end

function pth = iJoinSplitPath(pth, originalFileSep)
    %IJOINSPLITPATH Join the split paths generated from the InternalPaths object.
    % Join the split paths using the original filesep used to split at construction
    % time.

    if numel(pth) > 1
        % When we split a full file path, we already joined the filesep
        % to the first value.
        pth1 = pth(1);
        % Add a trailing filesep, which will be removed (emptied out) when splitting the path.
        pth = strcat(pth1, strjoin(pth(2:end), originalFileSep), originalFileSep);
    end
end

function pth = iSplitFullFile(pth, originalFileSep)
    %ISPLITFULLFILE Split a full file using the given filesep so the compression
    % ratio for the InternalPaths object is better.

    % strsplit has an option to collapse delimiters by default,
    % whereas string.split does not have such option.
    originalFileSep = regexptranslate('escape',originalFileSep);
    delim = ['(?:', originalFileSep, ')+'];
    [pth,m] = regexp(pth, delim, 'split', 'match');
    if ~isempty(m)
        % Add filesep to the root
        % This adds any UNC root separators or WIN drive roots
        % or IRI scheme file separators to the root.
        pth{1} = [pth{1}  m{1}];
    end
    % string split returns a column vector for a row vector input
    pth = pth(:)';
    if ~isempty(pth) && isempty(pth{end})
        % remove any trailing empty characters
        pth(end) = [];
    end
end

function sep = iFindCorrectFileSep(files)
    %IFINDCORRECTFILESEP Find the filesep based on the fileseparator
    % already present using the folder name of the first file.
    sep = filesep;
    if ispc && ~isempty(files)
        f = files{1};
        ind = find(f== '/'|f== '\', 1, 'first');
        if ~isempty(ind)
            sep = f(ind);
        end
    end
end

