function [classFile, virtual, otherFiles, classFileType] = ...
    classFiles(qname, classDir, type)
% classFiles Return a list of all files belonging to a class, given the
%   fully-qualified class name.
    import matlab.depfun.internal.MatlabType;
    import matlab.depfun.internal.requirementsConstants;
    fs = filesep;  % filesep is a function
    % If classDir is not provided, use WHICH to find the file
    if nargin == 1 || isempty(classDir) || numel(classDir) == 0
        classFile = matlab.depfun.internal.cacheWhich(qname);
    else
        dotIdx = strfind(qname, '.');
        if isempty(dotIdx)
            baseName = qname;
        else
            baseName = qname(dotIdx(end)+1:end);
        end
        classFile = [classDir fs baseName];        
    end
    otherFiles = {};
    virtual = false;
    
    % If the class file exists, determine its extension. If it doesn't,
    % arbitrarily assign '.m'.
    [classFileExists, clsFile] = matlabFileExists(classFile);
    
    if classFileExists
        classFile = clsFile;
    else
        virtual = true;
        classFile = [classFile '.m'];
    end

    % Determine the type of the class file. UDD and built-in classes:
    % pretty easy. MCOS and OOPS -- have to actually do some work.
    if isUDD(type)
        classFileType = MatlabType.UDDClass;
        singleFile = false;
    elseif type == MatlabType.NotYetKnown || ...
            (isMethod(type) && ~isBuiltin(type))
        [classFileType, singleFile] = classType(qname, classFile);
    else
        classFileType = type;
        singleFile = false;
        % It's a single file class if the type is built-in or the class 
        % file is a classdef file with no @'s in its path.
        if classFileType == MatlabType.BuiltinClass || ...
            (classFileExists && isempty(strfind(classFile, [fs '@'])) && ...
                isClassdef(classFile))
            singleFile = true;
        end
    end
    
    % Extract the base name of the class from the fully qualified name.
    className = strsplit(qname,'.');
    className = className{end};

    if classFileType == MatlabType.BuiltinClass
        bI = requirementsConstants.BuiltInStr;
        virtual = true;
        % If it starts with 'built-in' then it is a native MATLAB built-in
        % class, rather than one added by a toolbox, and there's path info
        % in the whichResult already. Otherwise, chop off any terminating
        % .m that the existence test above might have added -- the class
        % file must match the which result exactly, or an extra node will
        % be added to the graph with the differing name, and all the 
        % files that depend on this class won't be able to find it.
        if ~strncmp(bI,classFile,numel(bI))
            if classFile(end-1) == '.' && classFile(end) == 'm'
                classFile = classFile(1:end-2);
            end
        end
    end
    
    % Determine the class directory.
    %
    % This method is faster than fileparts, which matters, because classFiles
    % is called often: chop off the file name by removing everything after 
    % the last file separator.
    classDir = '';
    fileSepIdx = strfind(classFile,fs);
    if ~isempty(fileSepIdx)
       classDir = classFile(1:fileSepIdx(end)-1);                    
    end

    % Classes (not UDD) may be extended (have methods added to them) by
    % means of one or more @-directories. Look for those @-directories.
    % TODO: Make this faster. 
    extensionFiles = {};
    if classFileType ~= MatlabType.UDDClass
        extensionDir = findAtDirOnPath(qname);
        % Remove the class directory from the list of extension dirs.
        extensionDir = setdiff(extensionDir, classDir);
        extensionFiles = getClassDirFiles(extensionDir);
    end

    % If qname does not represent a single file class, and the path to the
    % class file has the structure .../@thing/thing.m, add all the files in 
    % the directory to the list of class files.
    atClassPattern = ['\' fs '@' className '\' fs className '\.m'];
    if ~singleFile && ~isempty(regexp(classFile, atClassPattern, 'once'))
        otherFiles = getClassDirFiles(classDir);
    end

    % If this is a UDD class, look for the constructor; we should have
    % picked up the class schema file from the @directory test above.
    if classFileType == MatlabType.UDDClass

        % Add constructor, if it exists.
        constuctorFile = strcat(classDir, fs, className, '.m');
        if matlab.depfun.internal.cacheExist(constuctorFile,'file')
            otherFiles = [otherFiles {constuctorFile}];
        end
    end
    % No duplicates.
    otherFiles = unique([otherFiles, extensionFiles]);
end

%---------------------------------------------------------------------------
function files = getClassDirFiles(classDir)
% getClassDirFiles Get all the files in the class directory and those in
% the private directory, if the class directory contains a private directory.
% If classDir is empty, return an empty cell array.
%
% classDir may be a cell array of multiple class directories. 
    files = {};

    function fList = getClassFiles(d)
        fList = getDirContents(d);
        fList = fullfile(d, fList);

        % If there is a private folder in the @-directory,
        % add all the files in that private folder.
        [privateFiles, privateDirName] = getPrivateFiles(d);
        privateFiles = strcat(privateDirName,filesep,privateFiles);
        
        fList = [fList; privateFiles];   
        fList = fList';
    end

    if iscell(classDir)
        for k=1:numel(classDir)
            files = [files getClassFiles(classDir{k})]; %#ok
        end
    elseif ~isempty(classDir) && numel(classDir) > 0
        files = getClassFiles(classDir);
    end
end

%---------------------------------------------------------------------------

function [pathName, varargout] = trimFullPath(fullFileName)
% trimFullPath  Strip off last piece from full path name    
% p = trimFullPath(fullpath) returns a modified path
% name minus the last substring of fullpath as delineated by filesep 
% characters. 
% [p substr] = trimFullPath(...) also returns the last 
% substring.  
    fs = filesep;
    if fullFileName(end) == fs
        fullFileName = fullFileName(1:end-1);
    end
    fileSepIdx = strfind(fullFileName, fs);
    pathName = fullFileName(1:fileSepIdx(end));
    if nargout == 2
        varargout{1} = fullFileName((fileSepIdx(end)+1):end); 
    end
end

