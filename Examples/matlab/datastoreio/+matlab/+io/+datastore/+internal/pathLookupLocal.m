function [files, filesizes] = pathLookupLocal(dirOrFile, includeSubfolders)
%PATHLOOKUPLOCAL Get file names and sizes resolved for a local input path.
%   FILES = pathLookup(PATH) returns the fully resolved file names for the
%   local or network path specified in PATH. This happens non-recursively
%   by default i.e. we do not look under subfolders while resolving. PATH
%   can be a single string denoting a path to a file or a folder. The path
%   can include wildcards.
%
%   FILES = pathLookup(PATH, INCLUDESUBFOLDERS) returns the fully resolved
%   file names for the local or network path specified in PATH taking
%   INCLUDESUBFOLDERS into account.
%   1) If a path refers to a single file, that file is added to the output.
%   2) If a path refers to a folder
%          i) all files in the specified folder are added to the output.
%         ii) if INCLUDESUBFOLDERS is false, subfolders are ignored.
%        iii) if INCLUDESUBFOLDERS is true, all files in all subfolders are
%             added.
%   3) If path refers to a wild card:
%          i) all files matching the pattern are added.
%         ii) if INCLUDESUBFOLDERS is false, folders that match the pattern
%              are looked up just for files.
%        iii) if INCLUDESUBFOLDERS is true, an error is thrown.
%
%   [FILES,FILESIZES] = pathLookupLocal(...) also returns the file sizes
%   for the resolved paths as an array of double values.
%
%   See also matlab.io.datastore.internal.pathLookup

%   Copyright 2015-2016, The MathWorks, Inc.

persistent fileseparator;
if isempty(fileseparator)
    fileseparator = filesep;
end
if ischar(dirOrFile)
    [files, filesizes] = getfullfiles(dirOrFile);
else
    error(message('MATLAB:datastoreio:pathlookup:invalidFilesInput'));
end
files = files(:);
filesizes = filesizes(:);

    function noFilesError(pth)
        error(message('MATLAB:datastoreio:pathlookup:fileNotFound',pth));
    end

    % Remove '.' and '..' from the directory listing
    function listing = removeDots(listing)
        idx = strcmp('.',listing) | strcmp('..',listing);
        listing(idx) = [];
    end

    % Helper to strcat the dirList and the actual file name listing
    % This is needed, because dir does not provide a fullpath option
    function listing = strcatListing(dirList, listing, customFileSep)
        if ~isempty(listing)
            nl = numel(listing);
            % do not use strcat which is incredibly slow on cellstrs
            % all we need is cating the char row vectors
            for i = 1:nl
                listing{i} = [dirList{i}, customFileSep, listing{i}];
            end
        end
    end

    function [files, filesizes] = getRecursiveListing(dirStruct, isfiles, pathStr, oneLevel)
        files = {};
        filesizes = [];
        dirList = removeDots({dirStruct(~isfiles).name});
        dirList = strcatListing(pathStr, dirList, fileseparator);
        while ~isempty(dirList)
            currentList = dirList;
            dirList = {};
            for ii = 1:length(currentList)
                currentDir = currentList{ii};
                currentDirStruct = dir(currentDir);
                currentIsfiles = not([currentDirStruct.isdir]);
                currentListing = strcat(currentDir, fileseparator, {currentDirStruct(currentIsfiles).name});
                files = [files, currentListing];
                filesizes = [filesizes, currentDirStruct(currentIsfiles).bytes];
                if ~oneLevel
                    currentDirList = removeDots({currentDirStruct(~currentIsfiles).name});
                    if ~isempty(currentDirList)
                        dirList = [dirList, strcat(currentDir, fileseparator, currentDirList)];
                    end
                end
            end
        end
    end

    function [files, filesizes] = getfullfiles(dof)
        files = {};
        filesizes = [];
        iswildcard = ~isempty(dof) && any(strfind(dof, '*'));
        if iswildcard && includeSubfolders
            error(message('MATLAB:datastoreio:pathlookup:wildCardWithIncludeSubfolders', dof));
        end
        dirStruct = dir(dof);
        if ~isempty(dirStruct)
            additionalListing = {};
            additionalFileSizes = [];
            isfiles = not([dirStruct.isdir]);
            listing = {dirStruct(isfiles).name};
            pathStr = {dirStruct.folder};
            customFileSep = fileseparator;
            filesOnlyPaths = pathStr(isfiles);
            if ~isempty(filesOnlyPaths)
                % Use empty char as fileseparator in case of root filenames,
                % because dir provides foldernames with a filesep if it's a root filename
                % This happens if an input is a filename in a root folder
                % eg. C:\my_C_drive_file.txt, /my_root_file.txt
                if filesOnlyPaths{1}(end) == fileseparator
                    % Check if the first path ends with a filesep and if so,
                    % empty char is the fileseparator for these files
                    customFileSep = '';
                end
            end
            listing = strcatListing(pathStr(isfiles), listing, customFileSep);
            if iswildcard
                % A wildcard on folders is provided.
                % Lookup onelevel down in to the wildcard matching folders.
                [additionalListing, additionalFileSizes] = ...
                    getRecursiveListing(dirStruct, isfiles, pathStr, true);
            elseif includeSubfolders
                [additionalListing, additionalFileSizes] = ...
                    getRecursiveListing(dirStruct, isfiles, pathStr, false);
            end
            files = [listing, additionalListing];
            filesizes = [dirStruct(isfiles).bytes, additionalFileSizes];
        elseif iswildcard
            noFilesError(dof);
        end

        if isempty(files)
            isexist = exist(dof, 'file');
            switch isexist
                case 7
                    if isempty(dirStruct)
                        % if the dirStruct itself is empty then there are no directories
                        % found. exist outputs 7 when the current directory name is provided
                        % as an input.
                        noFilesError(dof);
                    end
                    % Output of dir is not empty (. and ..)
                    error(message('MATLAB:datastoreio:pathlookup:emptyFolder',dof));
                case 2
                    % try to look it up as a partial path
                    files = which('-all',dof);
                    % reduce to one file if many
                    if numel(files) >= 1
                        files = files(1);
                        dirStruct = dir(files{1});
                        filesizes = dirStruct.bytes;
                        return;
                    end
            end
            noFilesError(dof);
        end
    end
end
