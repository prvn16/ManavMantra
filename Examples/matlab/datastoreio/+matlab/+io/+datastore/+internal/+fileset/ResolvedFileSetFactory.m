classdef (Sealed, Hidden) ResolvedFileSetFactory < matlab.mixin.Copyable
%ResolvedFileSetFactory A factory to build the correct ResolvedFileSet.
%
%   See also datastore, matlab.io.datastore.Partitionable.

%   Copyright 2017 The MathWorks, Inc.

    methods (Static)
        function fs = build(location, nvStruct)
            if ~isfield(nvStruct, 'FileInformationBuilt') || ~nvStruct.FileInformationBuilt
                import matlab.io.datastore.internal.fileset.ResolvedFileSetFactory;
                nvStruct = ResolvedFileSetFactory.buildFileInformation(location, nvStruct);
            end
            switch nvStruct.FullFilePaths
                case 'in-memory'
                    fs = matlab.io.datastore.internal.fileset.InMemoryFileSet(nvStruct);
                case 'compressed'
                    fs = matlab.io.datastore.internal.fileset.CompressedFileSet(nvStruct);
            end
        end

        function fs = buildInMemory(resolvedFiles, resolvedFileSizes)
            %BUILDINMEMORY Given already resolved files and file sizes this builds an in-memory fileset.
            %   This builds an in-memory fileset object given a list of already resolved
            %   files and file sizes. This is useful when we don't have to hit the file system over
            %   and over, if we know the files are already resolved and good to go.
            import matlab.io.datastore.internal.fileset.ResolvedFileSetFactory;
            nvStruct.FullFilePaths =  'in-memory';
            nvStruct.Files = resolvedFiles;
            nvStruct.FileSizes = resolvedFileSizes;
            nvStruct.FileSplitSize = 'file';
            nvStruct.StartOffset = 0;
            nvStruct.ActualFileSizeIfStruct = -1;
            fs = ResolvedFileSetFactory.buildFromFileInformation(nvStruct);
        end

        function [fs, fileExts, folderNames] = buildCompressed(location, nvStruct)
            %BUILDCOMPRESSED Given location and NV-pair struct, this builds a compressed fileset.
            %   This builds an in-memory fileset object given a list of already resolved
            %   files and file sizes. This is useful when we don't have to hit the file system over
            %   and over, if we know the files are already resolved and good to go.
            import matlab.io.datastore.internal.fileset.ResolvedFileSetFactory;
            nvStruct.FullFilePaths =  'compressed';
            nvStruct.FileSplitSize = 'file';
            nvStruct.StartOffset = 0;
            nvStruct.ActualFileSizeIfStruct = -1;
            nvStruct = ResolvedFileSetFactory.buildFileInformation(location, nvStruct);
            fs = ResolvedFileSetFactory.buildFromFileInformation(nvStruct);
            fileExts = nvStruct.FileExts;
            folderNames = iGetFolderNames(nvStruct);
        end

        function fs = buildFromFileInformation(nvStruct)
            %BUILDFROMFILEINFORMATION A helper to build a fileset object using already
            % built file information.
            import matlab.io.datastore.internal.fileset.ResolvedFileSetFactory;
            nvStruct.FileInformationBuilt = true;
            internalFs = ResolvedFileSetFactory.build({}, nvStruct);
            fs = matlab.io.datastore.DsFileSet({});
            fs.setInternalFileSet(internalFs);
        end

        function nvStruct = buildFileInformation(location, nvStruct)
            %BUILDFILEINFORMATION Given location and NV-pair struct build fileset information.
            %   Location input is the same as the location input DsFileSet object.
            %   Struct input can contain fields like IncludeSubfolders, FileExtensions, etc.
            %   The output struct will contain the files, file sizes, startOffset, and any information
            %   needed to construct either an in-memory or compressed fileset object.
            import matlab.io.datastore.internal.lookupAndFilterExtensions;
            import matlab.io.datastore.internal.fileset.ResolvedFileSet;

            nvStruct.ActualFileSizeIfStruct = ResolvedFileSet.DEFAULT_ACTUAL_FILE_SIZE_IF_NOT_STRUCT;
            if isequal(location, {})
                nvStruct.Files = {};
                nvStruct.FileSizes = [];
                nvStruct.FileExts = {};
                nvStruct.StartOffset = 0;
                return;
            end
            nvStruct.ForCompression = isequal(nvStruct.FullFilePaths, 'compressed');
            if ~isfield(nvStruct, 'DefaultFilterExtensions')
                nvStruct.DefaultFilterExtensions = {};
            end
            if isequal(nvStruct.DefaultFilterExtensions, {})
                import matlab.io.datastore.internal.validators.validateFileExtensions;
                isDefaultExts = validateFileExtensions(nvStruct.FileExtensions, nvStruct.UsingDefaults);
                args = {~isDefaultExts};
            else
                args = {};
            end
            if isstruct(location)
                if ~all(isfield(location, {'FileName', 'Size', 'Offset'}))
                    error(message('MATLAB:datastoreio:dsfileset:invalidStructLocation'));
                end
                % validate location.FileName
                iValidateFileName(location.FileName);

                files = location.FileName;
                fileSizes = iValidateNumericScalar(location.Size, ...
                    'MATLAB:datastoreio:dsfileset:invalidStructLocationSize');
                nvStruct.StartOffset = iValidateNumericScalar(location.Offset, ...
                    'MATLAB:datastoreio:dsfileset:invalidStructLocationOffset');

                % check if file exists. If so, find the full path.
                [~,nvStruct.Files, nvStruct.ActualFileSizeIfStruct, nvStruct.FileExts] = ...
                    lookupAndFilterExtensions(files, nvStruct, nvStruct.DefaultFilterExtensions, args{:});
                if nvStruct.StartOffset > nvStruct.ActualFileSizeIfStruct
                    % If Offset is greater than the file size, we should error, since seeking
                    % or reading from that offset is not possible.
                    error(message(...
                        'MATLAB:datastoreio:dsfileset:offsetGreaterthanSizeInStructLocation',...
                        nvStruct.ActualFileSizeIfStruct));
                elseif nvStruct.StartOffset + fileSizes > nvStruct.ActualFileSizeIfStruct
                    % Set size to be reasonable within the actual file size
                    % since splitting past the file size is unnecessary
                    fileSizes = nvStruct.ActualFileSizeIfStruct - nvStruct.StartOffset;
                end
                % Size from struct is the size of the file starting from the offset
                % which is fileSizes here.
                nvStruct.FileSizes = nvStruct.StartOffset + fileSizes;
            else
                [~,nvStruct.Files, nvStruct.FileSizes, nvStruct.FileExts] = ...
                    lookupAndFilterExtensions(location, nvStruct, nvStruct.DefaultFilterExtensions, args{:});
                nvStruct.StartOffset = 0;
            end
        end
    end
end

function iValidateFileName(fileName)
    import matlab.io.internal.validators.isString;
    import matlab.io.datastore.internal.indexOfFirstFolderOrWildCard;

    if ~isString(fileName)
        % error when filename is not a row character vector
        error(message('MATLAB:datastoreio:dsfileset:invalidStructLocationFileNameChar'));
    end
    idx = indexOfFirstFolderOrWildCard(fileName);

    if (-1 ~= idx)
        % error for folder or wild card inputs
        error(message('MATLAB:datastoreio:dsfileset:invalidStructLocationFileName', fileName));
    end

end

function numScalar = iValidateNumericScalar(numScalar, errorMsg)
    try
        classes = {'numeric'};
        attrs = {'scalar', 'nonnegative', 'integer'};
        validateattributes(numScalar, classes, attrs);
    catch ME
        error(message(errorMsg));
    end
    numScalar = double(numScalar);
end

function foldernames = iGetFolderNames(nvStruct)
    %IGETFOLDERNAMES Get a list of foldernames repmat'ed to the number of files
    % in the files list.
    % For example,
    %    {'/my/path/to/folder1', {2x1}}
    %    {'/my/path/to/folder2', {3x1}}
    % should return the foldernames as
    %    {'folder1';
    %     'folder1';
    %     'folder2';
    %     'folder2';
    %     'folder2';}
    if ~(isfield(nvStruct, 'NeedFolderNames') && nvStruct.NeedFolderNames) ...
        || isempty(nvStruct.Files)
        foldernames = {};
        return;
    end
    [~, foldernames] = cellfun(@fileparts, nvStruct.Files(:,1), 'UniformOutput', false);
    foldernames = cellfun(@(x,y)repmat({x},numel(y), 1), foldernames, nvStruct.Files(:,2), 'UniformOutput', false);
    foldernames = vertcat(foldernames{:});
end
