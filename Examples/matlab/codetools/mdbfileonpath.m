function varargout = mdbfileonpath(inFilename, resolveSymbolicLinks)
    %MDBFILEONPATH Helper function for the Editor/Debugger
    %   MDBFILEONPATH is passed a string containing an absolute filename of an
    %   file.
    %   It returns:
    %      a filename:
    %         the filename that will be run (may be a shadower)
    %         if file not found on the path and isn't shadowed, returns the
    %         filename passed in
    %      an integer defined in com.mathworks.mlwidgets.dialog.PathUpdateDialog
    %      describing the status:
    %         FILE_NOT_ON_PATH - file not on the path or error occurred
    %         FILE_WILL_RUN - file is the one MATLAB will run (or is shadowed by a newer
    %         p-file)
    %         FILE_SHADOWED_BY_PWD - file is shadowed by another file in the current directory
    %         FILE_SHADOWED_BY_TBX - file is shadowed by another file somewhere in the MATLAB path
    %         FILE_SHADOWED_BY_PFILE - file is shadowed by a p-file in the same directory
    %         FILE_SHADOWED_BY_MEXFILE - file is shadowed by a mex, mdl, or slx file in the same directory
    %         FILE_SHADOWED_BY_MLX - file is shadowed by a mlx file file somewhere in the MATLAB path
    %         FILE_SHADOWED_BY_MLAPP - file is shadowed by a mlapp file somewhere in the MATLAB path
    %
    %   inFilename should be an absolute filename with extension ".m" (no
    %   checking is done).    
    % 
    %   This file is for internal use only and is subject to change without
    %   notice.
    
    %   Copyright 1984-2014 The MathWorks, Inc.
     
    if nargin > 0
        try            
            if nargin == 1
                resolveSymbolicLinks = false;
            end
                        
            [path, fn] = fileparts(inFilename);
            
            import com.mathworks.jmi.MLFileUtils;
            import com.mathworks.services.mlx.MlxFileUtils;
            fileTypes = {
                {mexext, ... Mex file type
                    @()MLFileUtils.isNativeMexFile(inFilename), ...
                    @(path)getMexShadowStatus(path)}, ...
                {'slx', ... Simulink model .slx file type
                    @()MLFileUtils.isMdlFile(inFilename), ...
                    @(path)getMexShadowStatus(path)}, ...
                {'mdl', ... Simulink model .mdl file type
                    @()MLFileUtils.isMdlFile(inFilename), ...
                    @(path)getMexShadowStatus(path)}, ...
                {'mlx', ... MLX file type
                    @()MlxFileUtils.isMlxFile(inFilename), ...
                    @(path)getMlxFileShadowStatus(path)}, ...
                {'mlapp', ... MLAPP file type
                    @()MLFileUtils.isMlappFile(inFilename), ...
                    @(path)getMlappFileShadowStatus(path)}, ...
                {'p', ... P file type
                    @()MLFileUtils.isPFile(inFilename), ...
                    @(path)getPFileShadowStatus(path)}};
            
            for i=1:numel(fileTypes)
                fileTypeEntry = fileTypes{i};
                pathWithExt = fullfile(path, [fn '.' fileTypeEntry{1}]); 
                if (fileTypeEntry{2}())
                    break;
                elseif doesFileExist(pathWithExt)
                    fh = fileTypeEntry{3};
                    [shadowStatus, fullpath] = fh(pathWithExt);
                    break;
                end
            end
           
            if exist('shadowStatus', 'var') == 0
               [shadowStatus, fullpath] = checkIfShadowed(inFilename);
            end
          
            varargout{1} = fullpath;
            varargout{2} = shadowStatus;
        catch 
            varargout{1} = inFilename;
            varargout{2} = 0;
        end
    else
        varargout{1} = '';
        varargout{2} = 0;
    end
    
    function [shadowStatus, fullpath] = getMexShadowStatus(fullpath)
        % Mex shadow status returned for mex, mdl and slx.
        shadowStatus = com.mathworks.mlwidgets.dialog.PathUpdateDialog.FILE_SHADOWED_BY_MEXFILE;
    end

    function [shadowStatus, fullpath] = getPFileShadowStatus(fullpath)
        % Check if there is a p-file shadowing this file in the same
        % directory.  If there is (and if the ".m" file is newer), then
        % report that the p-file is shadowing it.
        mdirInfo = dir(inFilename);
        pdirInfo = dir(fullpath);
        % If the p-file is newer than the ".m" file, assume that it's OK
        if (pdirInfo.datenum >= mdirInfo.datenum)
            [shadowStatus, fullpath] = checkIfShadowed(internal.matlab.desktop.editor.unmapFilePath(fullpath));
        else
            shadowStatus = com.mathworks.mlwidgets.dialog.PathUpdateDialog.FILE_SHADOWED_BY_PFILE;
        end
    end

    function [shadowStatus, fullpath] = getMlxFileShadowStatus(fullpath)
        % Returning 'shadowed by MLX file' since this function is only 
        % called if an MLX file exists.
        shadowStatus = com.mathworks.mlwidgets.dialog.PathUpdateDialog.FILE_SHADOWED_BY_MLXFILE;
    end

    function [shadowStatus, fullpath] = getMlappFileShadowStatus(fullpath)
        % Returning 'shadowed by MLAPP file' since this function is only 
        % called if an MLAPP file exists.
        shadowStatus = com.mathworks.mlwidgets.dialog.PathUpdateDialog.FILE_SHADOWED_BY_MLAPPFILE;
    end
    
    function [shadowStatus, fullpath] = checkIfShadowed(inFilename)           
        [path, fn, ext] = filepartsWithoutPackages(inFilename);
        xfiletorun = getFileToRun(inFilename);
        import com.mathworks.mlwidgets.dialog.PathUpdateDialog;
        if ~isempty(xfiletorun)
            [xpath, xfn, xext] = filepartsWithoutPackages(xfiletorun);
            
            arePathsEqual = areDirectoriesEqual(xpath, path, resolveSymbolicLinks);
            areFileNamesEqual = areFilenamesEqualForRun(xfn, fn);
            areExtensionsEqual = areFilenamesEqualForRun(xext, ext);
            isExactFileNameMatch = areFileNamesEqual && areExtensionsEqual;
            areExtensionsCompatible = isStandardExtension(ext) && isStandardExtension(xext);
            
            areCompatibleFiles = areFileNamesEqual && areExtensionsCompatible;
            isPossibleShadow = ~arePathsEqual;
             
            %File will only run if the paths, the filename, and the extension match.
            if ~isPossibleShadow && isExactFileNameMatch   
                % The executable fileparts are identical to the file passed in
                fullpath = xfiletorun;                
                % MATLAB will run the file
                shadowStatus = PathUpdateDialog.FILE_WILL_RUN;
                
            %A file is shadowed only if the path are not equal, but the filename and extensions are compatible.
            elseif isPossibleShadow && areCompatibleFiles
                fullpath = xfiletorun;
                if areDirectoriesEqual(xpath, pwd, resolveSymbolicLinks)
                    shadowStatus = PathUpdateDialog.FILE_SHADOWED_BY_PWD;
                else
                    % shadower on path
                    shadowStatus = PathUpdateDialog.FILE_SHADOWED_BY_TBX;
                end
                
            %All other cases denote file that will not run.
            %The exception are files that will not run ever: g1564802.
            else
                fullpath = inFilename;
                shadowStatus = PathUpdateDialog.FILE_NOT_ON_PATH;
            end         
        else
            fullpath = inFilename;
            shadowStatus = PathUpdateDialog.FILE_NOT_ON_PATH;
        end
    end
end

%---------------------------------------------------------------------
% Like fileparts, but removes package ("\+foo") directories
function [outpath, outfile, outext] = filepartsWithoutPackages(inpath)
    [outpath, outfile, outext] = fileparts(inpath);
    outpath = removePackageDirs(outpath);
end

%---------------------------------------------------------------------
% Strip away the package directories from the given directory.
function result = removePackageDirs(inDir)
    result = inDir;
    % Make sure that result ends in a file separator so that the last item
    % is treated as a directory rather than a file. However, we don't wish
    % to return a value ending in a file separator from the method.
    while (~isempty(result) && isPackageDirectory(strcat(result, filesep)))
        result = fileparts(result);
    end
end

%---------------------------------------------------------------------
% Test if two strings containing directories are equal.  This takes
% platform considerations into account.
function pathsAreEqual = areDirectoriesEqual(path1, path2, resolveSymbolicLinks)

    % on Windows, compare normalized paths ignoring case. On other platforms, 
    % check whether the two normalized paths are equal.
    if ispc
        pathsAreEqual = strcmpi(com.mathworks.util.FileUtils.normalizePathname(path1), ...
            com.mathworks.util.FileUtils.normalizePathname(path2));
    else
        pathsAreEqual = isequal(com.mathworks.util.FileUtils.normalizePathname(path1), ...
            com.mathworks.util.FileUtils.normalizePathname(path2));
    end
     
    % Once this call sites gets cleaned up for only using PM2.0 branch, the 
    % use of resolveSymbolicLinks option can be completly removed, which 
    % includes signature of this function, mdbfileonpath and its call sites. 
    if feature('IsPM2.0')
        if ~pathsAreEqual
            rfs = com.mathworks.mlwidgets.explorer.model.realfs.RealFileSystem.getInstance();
            try
                resolved1 = rfs.resolve(rfs.getEntry(com.mathworks.matlab.api.explorer.FileLocation(path1))).getLocation();
            catch
                resolved1 = path1;
            end
            try
                resolved2 = rfs.resolve(rfs.getEntry(com.mathworks.matlab.api.explorer.FileLocation(path2))).getLocation();
            catch
                resolved2 = path2;
            end
            pathsAreEqual = resolved1.equals(resolved2);
        end
    else
        if resolveSymbolicLinks && ~pathsAreEqual
            rfs = com.mathworks.mlwidgets.explorer.model.realfs.RealFileSystem.getInstance();
            resolved1 = rfs.resolve(rfs.getEntry(com.mathworks.matlab.api.explorer.FileLocation(path1))).getLocation();
            resolved2 = rfs.resolve(rfs.getEntry(com.mathworks.matlab.api.explorer.FileLocation(path2))).getLocation();
            pathsAreEqual = resolved1.equals(resolved2);
        end
    end
    
end

%---------------------------------------------------------------------
% Test if two strings containing filenames are equal.  This is a case sensitive match because even though windows file
% system is case insensitive, MATLAB still uses case to determine what to run.
function namesAreEqual = areFilenamesEqualForRun(name1, name2)
    try
        namesAreEqual = strcmp(name1, name2);
    catch
        namesAreEqual = false;
    end
end

%---------------------------------------------------------------------
% Test if two strings containing filenames are equal.  This is a case sensitive match because even though windows file
% system is case insensitive, MATLAB still uses case to determine what to run.
function extAreStandard = isStandardExtension(ext)
    extAreStandard = any(areFilenamesEqualForRun(ext, {'.m', '.mlx', '.mlapp', '.p'}));
end

%---------------------------------------------------------------------
function fn = getFileToRun(inPath_arg)
    % Return a string containing the absolute path of the file that
    % MATLAB will run based on the input filename (e.g., foo)
    
    import com.mathworks.jmi.MatlabPath;
    
    if isFileInPackage(inPath_arg)
        % 1) For MCOS files, we need to determine whether the parent 
        %    directory for the package is on the path. If the parent 
        %    directory is not on the path, then return the empty string.
        parentPath = MatlabPath.getValidPathEntryParent(java.io.File(inPath_arg).getParentFile());
        if ~isDirectoryOnPath(char(parentPath.getPath))
            fn = '';
            return;
        end
        
        % 2) Next, determine what which thinks is the full path to the 
        %    class or method that we're trying to set a breakpoint in. 
        %    Then, look to see if the result of which is on the path (it 
        %    might not be if we're inside the class or package directory).
        whichResult = which(trimToMcosPath(inPath_arg));
        whichParentPath = MatlabPath.getValidPathEntryParent(java.io.File(whichResult).getParentFile());
        if isDirectoryOnPath(char(whichParentPath.getPath))
           fn = whichResult;
           return;
        end
        
        % 3) Finally, if the given file is on the path, and not found by
        %    which, simply return the given file.
        fn = inPath_arg;
    elseif isPrivate(inPath_arg)
        % For files in a private use absolute path
        fn = which(inPath_arg);
    else  % make the variable names somewhat obscure -- geck 281208
        [~, fileparts_Filename_Var] = fileparts(inPath_arg);
        fn = which(fileparts_Filename_Var);
        % correct returned built-ins to point to their matching file for the purposes of command-line help -- geck 376452
        if ( 1 ==strfind( fn, 'built-in (' ) )
            fn = fn(length('built-in (')+1:length(fn)-1); % e.g. matlabroot '/toolbox/matlab/ops/@single/plus'
            fn = [fn '.m'];
        end
    end
end


%---------------------------------------------------------------------
function result = trimToMcosPath(filepath)
    % Trims away the part of the path that is not related to the MCOS name.
    % See the corresponding Java method MatlabPath.trimToMcosPath for more
    % details.
    
    result = char(com.mathworks.jmi.MatlabPath.trimToMcosPath(filepath));
end


%---------------------------------------------------------------------
% Does the given file live in a private directory? Argument must represent
% a file and therefore not end in a file separator.
function result = isPrivate(inFile)
    assert(~isdir(inFile), ['argument must be a file, not a directory: ' inFile]);
    result = com.mathworks.jmi.MatlabPath.isPrivate(fileparts(inFile));
end

%---------------------------------------------------------------------
% Does the given file live in an MCOS class directory? Argument must
% represent a file and therefore not end in a file separator.
function result = isObject(inFile)
    assert(~isdir(inFile), ['argument must be a file, not a directory: ' inFile]);
    result = com.mathworks.jmi.MatlabPath.isObject(fileparts(inFile));
end

%---------------------------------------------------------------------
% Does the given file live in an MCOS package? Argument must not end in a
% file separator.
function result = isFileInPackage(inFile)
    assert(~isdir(inFile), ['argument must be a file, not a directory: ' inFile]);
    result = isPackageDirectory(fileparts(inFile));
end

%---------------------------------------------------------------------
% Does the given directory represent an MCOS package? See comments in
% MatlabPath.isPackage. Argument must end in a file separator.
function result = isPackageDirectory(inDir)
    if isdir(inDir) == 0
        result = false;
    else
        result = com.mathworks.jmi.MatlabPath.isPackage(inDir);
    end
end

%---------------------------------------------------------------------
% This returns true only if inFilename's case matches what is on disk.
% This function is used instead of the 'exist' function because we want to
% differentiate files 'FOO.m' and 'foo.m' when on UNIX.  The 'exist'
% function will return 2 regardless of the case of the string that is
% passed in.
function existsOnDisk = doesFileExist(inFilename)
    fileObject = java.io.File(inFilename);
    existsOnDisk = false;
    if isempty(fileObject)
        return;
    else
        try
            if fileObject.exists && fileObject.isFile
                [~, fn1] = fileparts(inFilename);
                filename2 = char(fileObject.getCanonicalPath);
                [~, fn2] = fileparts(filename2);
                if isequal(fn1, fn2)
                    existsOnDisk = true;
                end
            end
        catch
            existsOnDisk = false;
        end
    end
end

function isOnPath = isDirectoryOnPath(directory)
% returns true if the given directory is on the path (including pwd).
    
    assert(exist(directory, 'dir') == 7);
    
    % determine if the directory is on the path, either implicitly
    % by being on pwd, or explicitly by being on the actual path.
    cellOfPathEntries = regexp(path, pathsep, 'split');
    cellOfPathEntries{end+1} = pwd;
    isOnPath = ~isempty(find(doPlatformBasedPathComparison(cellOfPathEntries, directory), 1));
    
end

function areEqual = doPlatformBasedPathComparison(cellOfPathEntries, directory)
% returns true if the given directory is contained within the given cell
% array of path entries. this function takes into account the fact that the
% path is case-sensitive on Mac and Linux, while case-insensitive on 
% Windows.
    if ispc
        areEqual = strcmpi(cellOfPathEntries, directory);
    else
        areEqual = strcmp(cellOfPathEntries, directory);
    end
end
