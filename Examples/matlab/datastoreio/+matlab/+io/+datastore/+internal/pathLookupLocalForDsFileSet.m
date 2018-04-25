function [files, filesizes] = pathLookupLocalForDsFileSet(dirOrFile, includeSubfolders)
%PATHLOOKUPLOCAL Get file names and sizes resolved for a local input path for DsFileSet.
%   FILES = pathLookupLocalForDsFileSet(PATH) returns the fully resolved file names for the
%   local or network path specified in PATH. This happens non-recursively
%   by default i.e. we do not look under subfolders while resolving. PATH
%   can be a single string denoting a path to a file or a folder. The path
%   can include wildcards. This provides files in a compresssed form separated
%   by folders and a list of files each corresponding to each of the folder.
%
%   FILES = pathLookupLocalForDsFileSet(PATH, INCLUDESUBFOLDERS) returns the fully resolved
%   file names for the local or network path specified in PATH taking
%   INCLUDESUBFOLDERS into account.
%   This provides files in a compresssed form separated by folders and a list
%   of files each corresponding to each of the folder.
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
%   [FILES,FILESIZES] = pathLookupLocalForDsFileSet(...) also returns the file sizes
%   for the resolved paths as an array of double values.
%
%   See also matlab.io.datastore.internal.pathLookup

%   Copyright 2017, The MathWorks, Inc.

persistent fileseparator;
if isempty(fileseparator)
    fileseparator = filesep;
end
if nargin == 1
    includeSubfolders = false;
end

iswildcard = ~isempty(dirOrFile) && any(strfind(dirOrFile, '*'));
if iswildcard && includeSubfolders
    error(message('MATLAB:datastoreio:pathlookup:wildCardWithIncludeSubfolders', dirOrFile));
end

RECURSE_STR = '/**/*';
if includeSubfolders
    dirOrFileArg = fullfile(dirOrFile, RECURSE_STR);
else
    dirOrFileArg = dirOrFile;
end
dirStruct = dir(dirOrFileArg);
isfiles = not([dirStruct.isdir]);
files = dirStruct(isfiles);
if isempty(dirStruct) || isempty(files)
    % if empty, try to lookup MATLAB path.
    dirStruct = lookupMATLABPath(dirStruct, dirOrFileArg, dirOrFile, includeSubfolders);
    isfiles = not([dirStruct.isdir]);
    files = dirStruct(isfiles);
end
listing = {files.name};
pathStr = {files.folder};
filesizes = [files.bytes];
listing = listing(:);
pathStr = pathStr(:);
filesizes = filesizes(:);
if numel(filesizes) == 1
    files = [pathStr, {listing}];
    return;
end
% We need to group folders and the respective file names into cell array.
[folders, ~, groupIndices] = unique(pathStr, 'stable');
if numel(folders) == 1
    listing = {listing};
else
    listing = splitapply(@(x){vertcat(x)}, listing, groupIndices);
end
% A 2D cell containing the foldernames and file names.
% For a folder with 10 files, first element is the full folder name
% and the corresponding 2-Dim element is the list of 10 file names.
files = [folders, listing];

    function dirStruct = lookupMATLABPath(dirStruct, dirOrFileArg, dirOrFile, paddedRecurseWildCard)
        if paddedRecurseWildCard
            % We need to use the original input in case we padded the string
            % with recurse wild card: /**/*
            dirOrFileArg = dirOrFile;
        end
        isexist = exist(dirOrFileArg, 'file');
        switch isexist
            case 7
                if isempty(dirStruct)
                    % if the dirStruct itself is empty then there are no directories
                    % found. exist outputs 7 when the current directory name is provided
                    % as an input.
                    noFilesError(dirOrFileArg);
                end
                % Output of dir is not empty (. and ..)
                error(message('MATLAB:datastoreio:pathlookup:emptyFolder',dirOrFileArg));
            case 2
                dirStruct = dir(dirOrFileArg);
                if ~isempty(dirStruct)
                    return;
                end
                % try to look it up as a partial path
                files = which('-all',dirOrFileArg);
                % reduce to one file if many
                if numel(files) >= 1
                    files = files(1);
                    dirStruct = dir(files{1});
                    return;
                end
        end
        noFilesError(dirOrFileArg);
    end

    function noFilesError(pth)
        error(message('MATLAB:datastoreio:pathlookup:fileNotFound',pth));
    end
end
