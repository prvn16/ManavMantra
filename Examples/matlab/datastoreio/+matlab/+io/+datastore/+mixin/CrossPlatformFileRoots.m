classdef (Hidden, Abstract) CrossPlatformFileRoots < handle
%CROSSPLATFORMROOTS Support for cross platform roots for files.
%   This mixin class can be added to all file based datastores when
%   they need to support cross platform roots for files.

%   Copyright 2017 The MathWorks, Inc.

    properties (Access = protected)
        %CREATEDONPC We want to use this to replace only for slashes
        CreatedOnPC = ispc;
        %MULTIPLEFILESEPS If set to true, the files have multiple file seps on various files on PC.
        MultipleFileSeps = false;
        %BACKSLASHINDICES Can be 'all' or empty or logical indices for to replace on PC.
        BackSlashIndices = [];
        SetFromLoadObj = false;
    end

    properties
        %ALTERNATEFILESYSTEMROOTS Alternate file system roots for the files.
        %   Alternate file system root paths for the files provided in the
        %   LOCATION argument. ALTROOTS contains one or more rows, where each row
        %   specifies a set of equivalent root paths. Values for ALTROOTS can be one
        %   of these:
        %
        %      - A string row vector of root paths, such as
        %                 ["Z:\datasets", "/mynetwork/datasets"]
        %
        %      - A cell array of root paths, where each row of the cell array can be
        %        specified as string row vector or a cell array of character vectors,
        %        such as
        %                 {["Z:\datasets", "/mynetwork/datasets"];...
        %                  ["Y:\datasets", "/mynetwork2/datasets","S:\datasets"]}
        %        or
        %                 {{'Z:\datasets','/mynetwork/datasets'};...
        %                  {'Y:\datasets', '/mynetwork2/datasets','S:\datasets'}}
        AlternateFileSystemRoots = {};
    end

    properties (Constant, Access = protected)
        ALTERNATE_FILESYSTEM_ROOTS_NV_NAME = 'AlternateFileSystemRoots';
        DEFAULT_ALTERNATE_FILESYSTEM_ROOTS = {};
        CLOUD_PATH_IRI_SCHEMES = {'s3://', 'wasb://', 'wasbs://', 'hdfs:/'};
    end

    methods (Abstract, Access = protected)
        % Subclasses need to implement whether files are empty or not.
        tf = isEmptyFiles(ds);
        % Subclasses need to implement how to set the transformed files.
        setTransformedFiles(ds, files);
        % Subclasses need to implement how to get the files to be transformed.
        files = getFilesForTransform(ds);
    end

    methods (Access = protected)

        %DEFAULTSETFROMLOADOBJ Set SetFromLoadObj property to default 'false' value.
        function defaultSetFromLoadObj(ds)
            ds.SetFromLoadObj = false;
        end

        %ISSETFROMLOADOBJ Check if SetFromLoadObj property is true.
        function tf = isSetFromLoadObj(ds)
            tf = ds.SetFromLoadObj == true;
        end

        %UPDATEFILESFROMPATHMAP Update the Files property or an equivalent, based on the AlternateFileSystemRoots values.
        function updateFilesFromPathMap(ds, aFolders)
            import matlab.io.datastore.mixin.CrossPlatformFileRoots;
            if isempty(aFolders)
                return;
            end
            if iscellstr(aFolders)
                aFolders = {aFolders};
            end
            numFolders = numel(aFolders);
            nonExisting = false;
            inFiles = getFilesForTransform(ds);
            existing = false(numFolders, 1);
            for ii = 1:numFolders
                aPath = aFolders{ii};
                [isAbsOrFile,cloudPaths] = iLookAtNonCloud(aPath, CrossPlatformFileRoots.CLOUD_PATH_IRI_SCHEMES);
                if any(isAbsOrFile(:,1))
                    relativePaths = join(aPath(isAbsOrFile(:,1)), ', ');
                    error(message('MATLAB:datastoreio:filebaseddatastore:relativePathsUnsupported', relativePaths{1}));
                end
                isAbsOrFile = iLookAtCloudIfNecessary(isAbsOrFile, inFiles, aPath, cloudPaths);
                ex = isAbsOrFile(:,2);
                existing(ii) = any(ex);
                if ~existing(ii)
                    continue;
                end
                aPath = iRemoveTrailingSep(aPath);
                aFolders{ii} = aPath;
                if all(ex)
                    continue;
                end
                rep = aPath(ex);
                if numel(rep) > 1
                    rep = rep(1);
                end
                nonExistingPaths = iAddTrailingSep(aPath(~ex));
                nonExisting = startsWith(inFiles, nonExistingPaths);
                if any(nonExisting)
                    inFiles(nonExisting) = iReplaceNonExisting(inFiles(nonExisting), aPath(~ex), rep);
                end
            end

            if ~any(existing)
                noEntryRoots = join(iCatAllAltPaths(aFolders), ', ');
                error(message('MATLAB:datastoreio:filebaseddatastore:noAlternateFileSystemRootsExist', noEntryRoots{1}));
            end

            allPaths = iCatAllAltPaths(aFolders);
            if ~any(startsWith(inFiles, allPaths))
                noEntryRoots = join(allPaths, ', ');
                error(message('MATLAB:datastoreio:filebaseddatastore:noEntryMatchesFiles', noEntryRoots{1}));
            end

            if any(nonExisting)
                ds.setTransformedFiles(inFiles);
            end
        end

        %REPLACEUNCPATHS If AlternateFileSystemRoots is empty, relace the UNC paths appropriate
        % to a platform.
        function replaceUNCPaths(ds)
            if isempty(ds.AlternateFileSystemRoots)
                files = getFilesForTransform(ds);
                if ispc
                    startsWithChar = '/';
                    repThis= '/';
                    repBetFcn =@(x)replaceBetween(x,1,1,'\\');
                else
                    startsWithChar = '\\';
                    repThis= '\';
                    repBetFcn =@(x)replaceBetween(x,1,2,'/');
                end
                uncPaths = startsWith(files, startsWithChar);
                if any(uncPaths)
                    files(uncPaths) = replace(files(uncPaths), repThis, filesep);
                    files(uncPaths) = repBetFcn(files(uncPaths));
                    ds.setTransformedFiles(files);
                end
            end
        end
    end

    methods
        % Setter for AlternateFileSystemRoots
        function set.AlternateFileSystemRoots(ds, aFolders)
            try
                if ~isSetFromLoadObj(ds)
                    aFolders = convertStringsToChars(aFolders);
                    aFolders = iValidateAlternateFileSystemRoots(aFolders);
                    updateFilesFromPathMap(ds, aFolders);
                else
                    % On loadobj we want to throw the exception (that converts to warning)
                    % and also not lose the property value.
                    try
                        updateFilesFromPathMap(ds, aFolders);
                    catch ME
                        onState = warning('off', 'backtrace');
                        c = onCleanup(@() warning(onState));
                        warning(ME.identifier, '%s', ME.message);
                    end
                end
                ds.AlternateFileSystemRoots = aFolders;
                if ~isSetFromLoadObj(ds)
                    reset(ds);
                end
            catch e
                throw(e)
            end
        end
    end
end

function apaths = iValidateAlternateFileSystemRoots(apaths)
    if iscell(apaths) && isempty(apaths)
        return;
    end
    if ischar(apaths) || ~iscell(apaths) || (iscellstr(apaths) && numel(apaths) < 2) ...
        || (iscell(apaths) && any(~cellfun(@(x) isStringPathVector(x) || isCharPath(x) || isCellCharPath(x), apaths)))
        error(message('MATLAB:datastoreio:filebaseddatastore:invalidAlternateFileSystemRoots'));
    end
    if iscell(apaths) && isstring(apaths{1})
        apaths = cellfun(@cellstr, apaths, 'UniformOutput', false);
    end
    catpaths = iCatAllAltPaths(apaths);
    indices = 1:numel(catpaths);
    arrayfun(@(x,y)iValidateStartsWithPath(x, catpaths, y), catpaths, indices(:));
end

function iValidateStartsWithPath(pth, allPaths, i)
    allPaths(i) = [];
    sep = "\";
    if isempty(strfind(pth, sep))
        sep = "/";
    end
    sw = startsWith(allPaths + sep, pth + sep);
    if any(sw)
        swPath = allPaths(sw);
        error(message('MATLAB:datastoreio:filebaseddatastore:ambiguousAlternateFileSystemRoots', pth, swPath(1)));
    end
end

function tf = isCharPath(pth)
    tf = ischar(pth) && isrow(pth) && numel(pth) > 1;
end

function tf = isStringPathVector(pth)
    tf = isstring(pth) && isvector(pth) && numel(pth) > 1 && all(strlength(pth) > 1);
end

function tf = isCellCharPath(pth)
    tf = iscell(pth) && all(cellfun(@isCharPath, pth)) && numel(pth) > 1;
end

function aPath = iRemoveTrailingSep(aPath)
    %IREMOVETRAILINGSEP Removes trailing file separators.
    if ispc
        dirSep = {'\', '/'};
    else
        dirSep = {'/'};
    end
    trailingSep = endsWith(aPath, dirSep);
    if any(trailingSep)
        for ii = 1:numel(dirSep)
            aPath(trailingSep) = strip(aPath(trailingSep), 'right', dirSep{ii});
        end
    end
end

function [isAbsOrFile,cloudPaths] = iLookAtNonCloud(aPath, cloudIRISchemes)
    %ILOOKATNONCLOUD We want to look at the non-cloud paths first
    %   The cloud paths take longer to lookup as it stands now.
    %   Look at the non-cloud paths first, if any non-cloud paths exist, then use
    %   them as the chosen alternate path.
    import matlab.io.datastore.internal.isAbsoluteFolder;
    cloudPaths = startsWith(aPath, cloudIRISchemes);
    if any(cloudPaths)
        isAbsOrFile = false(numel(aPath), 2);
        isAbsOrFile(cloudPaths,1) = false;
        isAbsOrFile(~cloudPaths,:) = isAbsoluteFolder(aPath(~cloudPaths));
        if any(isAbsOrFile(:,2))
            return;
        end
        isAbsOrFile(cloudPaths,:) = isAbsoluteFolder(aPath(cloudPaths));
    else
        isAbsOrFile = isAbsoluteFolder(aPath);
    end
    if ~ispc
        % Mark any folder that starts with '~' as relative.
        tildeRelative = startsWith(aPath(isAbsOrFile(:,2)), '~');
        isAbsOrFile(tildeRelative,1) = true;
    end
end

function isAbsOrFile = iLookAtCloudIfNecessary(isAbsOrFile, inFiles, aPath, cloudPaths)
    %ILOOKATCLOUDIFNECESSARY We want to look at the cloud paths only when necessary
    %   Since the cloud paths take longer to lookup as it stands now we look at the
    %   non-cloud paths first. If the input files contain any cloud paths, we want to look
    %   at them for existence.
    if any(cloudPaths)
        cloudPathInFiles = startsWith(inFiles, aPath(cloudPaths));
        if any(cloudPathInFiles)
            import matlab.io.datastore.internal.isAbsoluteFolder;
            cloudInFiles = inFiles(cloudPathInFiles);
            needsLookup = arrayfun(@(x)any(startsWith(cloudInFiles,x)), aPath(cloudPaths));
            if any(needsLookup)
                cloudIndices = find(cloudPaths);
                pathsForLookup = aPath(cloudIndices(needsLookup));
                noTrailingSep = ~endsWith(pathsForLookup, '/');
                % Paths like "hdfs://mycluster:[port#]/myfolder" can be part of the files, but
                % alternate paths like "hdfs://mycluster:[port#]" will not be found by the
                % path lookup api. Adding a trailing sep will make sure these paths exist
                % or not.
                pathsForLookup(noTrailingSep) = strcat(pathsForLookup(noTrailingSep), '/');
                isAbsOrFile(cloudIndices(needsLookup),:) = isAbsoluteFolder(pathsForLookup);
            end
        end
    end
end

function nonExistingInFiles = iReplaceNonExisting(nonExistingInFiles, nonExistingAltPath, replacement)
    nonExistingInFiles = replace(nonExistingInFiles, nonExistingAltPath, replacement);
    [fileSeparator, replaceThis]  = iFindFileSeparator(replacement);
    nonExistingInFiles = replace(nonExistingInFiles, replaceThis, fileSeparator);
end

function [fileSeparator, replaceThis]  = iFindFileSeparator(replacement)
    switch class(replacement)
        case 'cell'
            replacement = replacement{1};
        case 'string'
            replacement = char(replacement);
    end
    ind = find(replacement== '/'| replacement== '\', 1, 'first');
    if ~isempty(ind)
        fileSeparator = replacement(ind);
        if fileSeparator == '\'
            replaceThis = '/';
        else
            replaceThis = '\';
        end
        return;
    end
    % Match Windows-Drive-Only paths, like "C:", "d:" or "Z:"
    if ~isempty(regexp(replacement, "^([A-Z]|[a-z]:)$"))
        fileSeparator = '\';
        replaceThis = '/';
        return;
    end
    fileSeparator = '/';
    replaceThis = '\';
end

function altPaths = iAddTrailingSep(altPaths)
    %IADDTRAILINGSEP This adds trailing separator to the alternate paths provided
    %   Add forward/back slashes to the respective paths. If no slashes are found in
    %   some paths add
    %     - back slash only for Windows-Drive-Only paths, like "C:", "d:" or "Z:"
    %     - otherwise add forward slash.
    %   Note:
    %     Call this after making sure trailing seps are removed from the alternate paths.
    altPaths = string(altPaths);
    forwardSlash = contains(altPaths, '/');
    backSlash = contains(altPaths, '\');
    altPaths(forwardSlash) = altPaths(forwardSlash) + '/';
    altPaths(backSlash) = altPaths(backSlash) + '\';
    noSlashes = ~(forwardSlash | backSlash);
    if any(noSlashes)
        noSlashPaths = altPaths(noSlashes);
        % Match Windows-Drive-Only paths, like "C:", "d:" or "Z:"
        winDrivePaths = regexp(noSlashPaths, "^([A-Z]|[a-z]:)$");
        if iscell(winDrivePaths)
            winDrivePaths = ~cellfun(@isempty, winDrivePaths);
        end
        anyWinDrivePaths = any(winDrivePaths);
        anyNonWinDrivePaths = any(~winDrivePaths);
        if anyWinDrivePaths
            noSlashPaths(winDrivePaths) = noSlashPaths(winDrivePaths) + '\';
        end
        if anyNonWinDrivePaths
            noSlashPaths(~winDrivePaths) = noSlashPaths(~winDrivePaths) + '\';
        end
        if anyWinDrivePaths || anyNonWinDrivePaths
            altPaths(noSlashes) = noSlashPaths;
        end
    end
    altPaths = cellstr(altPaths);
end

function catpaths = iCatAllAltPaths(catpaths)
    if ~iscellstr(catpaths)
        numPaths = numel(catpaths);
        combpaths = cell(numPaths, 1);
        for i = 1:numPaths
            c = catpaths{i};
            combpaths{i} = c(:);
        end
        catpaths = vertcat(combpaths{:});
    end
    catpaths = string(catpaths(:));
end
