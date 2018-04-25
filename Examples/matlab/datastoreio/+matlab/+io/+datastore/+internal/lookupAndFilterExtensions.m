function [tf, loc, fileSizes, fileExts] = lookupAndFilterExtensions(loc, nvStruct, defaultExtensions, filterExtensions)
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
    if nargout > 2
        [loc, fileSizes] = pathLookup(loc, nvStruct.IncludeSubfolders, noSuggestionInEmptyFolderErr, nvStruct.ForCompression);
    else
        loc = pathLookup(loc, nvStruct.IncludeSubfolders, noSuggestionInEmptyFolderErr, nvStruct.ForCompression);
    end
    if isempty(loc)
        szLoc = 0;
    elseif nvStruct.ForCompression
        szLoc = [sum(cellfun(@numel, loc(:, 2))), 1];
    else
        szLoc = size(loc);
    end
    % filter based on extensions
    filterExts = true(szLoc);
    fileExts = cell(szLoc);
    isFiltered = false;
    if nargin < 4 || filterExtensions
        if nvStruct.ForCompression
            j = 1;
            iiSize = size(loc,1);
            emptyIndexes = false(szLoc);
            for ii = 1:iiSize
                files = loc{ii, 2};
                numFiles = numel(files);
                filterLoc = true(numFiles, 1);
                for i = 1:numFiles
                    [~,~,ext] = fileparts(files{i});
                    if ~any(strcmpi(allowedExts, ext))
                        filterLoc(i) = false;
                        filterExts(j) = false;
                        isFiltered = true;
                    end
                    fileExts{j} = ext;
                    j = j + 1;
                end
                files = files(filterLoc);
                if isempty(files)
                    % remove the directory and files
                    % if all are filtered
                    emptyIndexes(ii) = true;
                else
                    loc{ii, 2} = files;
                end
            end
            loc(emptyIndexes,:) = [];
        else
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
