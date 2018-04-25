function edit(varargin)
%EDIT Edit or create M-file
%   EDIT FUN opens the file FUN.M in a text editor.  FUN must be the
%   name of an M-file or a MATLABPATH relative partial pathname (see
%   PARTIALPATH).
%
%   EDIT FILE.EXT opens the specified file.  MAT and MDL files will
%   only be opened if the extension is specified.  P and MEX files
%   are binary and cannot be directly edited.
%
%   EDIT X Y Z ... will attempt to open all specified files in an
%   editor.  Each argument is treated independently.
%
%   EDIT, by itself, opens up a new editor window.
%
%   If the specified file does not exist and the user is using the
%   MATLAB built-in editor, an empty file may be opened depending on
%   the Editor/Debugger Preferences.  If the user has specified a
%   different editor, the name of the non-existent file will always
%   be passed to the other editor.
%   Copyright 1984-2017 The MathWorks, Inc.

if ~iscellstr(varargin)
    error(makeErrID('NotString'), 'The input must be a string.');
end

try
    if (nargin == 0)
        openEditor;
    elseif (nargin > 1)
        error(makeErrID('MaxNumOfFiles'), 'Too many input arguments for this product offering.  Edit only 1 file at a time.');
    else
        for i = 1:nargin
            argName = translateUserHomeDirectory(strtrim(varargin{i}));
            if isempty(argName)
                openEditor;
            elseif ~openInPrivateOfCallingFile(argName)
                if ~openOperator(argName)
                    if ~openWithFileSystem(argName, ~isSimpleFile(argName))
                        if ~openPath(argName)
                            showEmptyFile(argName);
                        end
                    end
                end
            end
        end
    end
catch exception
    exception.throwAsCaller; % throw so that we don't display stack trace
end

%--------------------------------------------------------------------------
% Create a new file called untitled<n>.m in the current directory
%--------------------------------------------------------------------------
function createUntitled()

import com.mathworks.matlabserver.workercommon.client.*;
clientServiceRegistryFacade = ClientServiceRegistryFactory.getClientServiceRegistryFacade();
editorService = clientServiceRegistryFacade.getEditorService();

basename = 'untitled';
ext = '.m';

name = [basename ext];
i = 1;
while exist(name,'file') && i < 100
    name = [basename int2str(i) ext];
    i = i+1;
end

if exist(name,'file')
    error(message('MATLAB:connector:Platform:NoAvailableUntitledName'));
end

editorService.createOrOpenFile(fullfile(pwd, name));

%--------------------------------------------------------------------------
% Create or open a file with the full absolute path: 'file'
%--------------------------------------------------------------------------
function createOrOpenFile(file)

import com.mathworks.matlabserver.workercommon.client.*;
clientServiceRegistryFacade = ClientServiceRegistryFactory.getClientServiceRegistryFacade();
editorService = clientServiceRegistryFacade.getEditorService();
editorService.createOrOpenFile(file);


%--------------------------------------------------------------------------
% Special case for opening invoking 'edit' from inside of a function:
%   function foo
%   edit bar
% In the case above, we should be able to pick up private/bar.m from
% inside foo.
function opened = openInPrivateOfCallingFile(argName)
opened = false;
st = dbstack('-completenames');
% if there are more than two frames on the stack, then edit was called from
% a function
if length(st) > 2
    dirName = fileparts(st(3).file);
    privateName = fullfile(dirName, 'private', argName);
    opened = openWithFileSystem(privateName, false);
end

%--------------------------------------------------------------------------
% Helper function that displays an empty file -- taken from the previous edit.m
% Now passes error message to main function for display through error.
function showEmptyFile(file)
errMessage = '';
errID = '';

% If nothing is found in the MATLAB workspace or directories,
% open a blank buffer only if:
%   1) the given file is a simple filename (contains no qualifying 
%      directories, i.e. foo.m) 
%   OR 
%   2) the given file's directory portion exists (note that to get into 
%      this method it is implied that the file portion does not exist)
%      (i.e. myDir/foo.m, where myDir exists and foo.m does not).
[path, fileNameWithoutExtension, extension] = fileparts(file);

if isSimpleFile(file) || (exist(path, 'dir') == 7)
    
    % build the file name with extension.
    if isempty(extension) 
        extension = '.m';
    end
    fileName = [fileNameWithoutExtension extension];

    % make sure the given file name is valid.
    checkValidName(fileName);
    
    % if the path is empty then use the current working directory.
    % else use the fully resolved version of the given path.
    if (strcmp(path, ''))
       path = pwd;
    else
        whatStruct = what(path);
        path = whatStruct.path;
    end
     
    openEditor(fullfile(path,fileName));
else
    [errMessage, errID] = showFileNotFound(file, false);
end
handleError(errMessage, errID);

%--------------------------------------------------------------------------
function result = getBooleanPref(prefname, defaultValue)
prefValue = system_dependent('getpref', prefname);
if (~isempty(strfind(prefValue, 'Bfalse')))
    result = false;
elseif (~isempty(strfind(prefValue, 'Btrue')))
    result = true;
else
    result = defaultValue;
end

%--------------------------------------------------------------------------
function result = getStringPref(prefname, defaultValue)
% If Java is available, use the Java Prefs API so that we ensure proper
% translation of \u0000-encoded characters. Otherwise, just accept the
% string as-is, knowing that encoding characters in the path might not
% work.
if isempty(checkJavaAvailable)
    result = char(com.mathworks.services.Prefs.getStringPref(...
        prefname, defaultValue));
else
    prefValue = system_dependent('getpref', prefname);
    if (length(prefValue) > 1)
        result = prefValue(2:end);
    else
        result = defaultValue;
    end
end


%--------------------------------------------------------------------------
% Returns the non-MATLAB external editor.
function result = getOtherEditor
result = getStringPref('EditorOtherEditor', '');

%--------------------------------------------------------------------------
% Returns if Java is available (for -nojvm option).
function result = checkJavaAvailable
result = javachk('swing', 'The MATLAB Editor');
 
%--------------------------------------------------------------------------
% Helper function that calls the java editor.  Taken from the original edit.m.
% Did modify to pass non-existent files to outside editors if
% user has chosen not to use the built-in editor.
% Also now passing out all error messages for proper display through error.
% It is possible that this is incorrect (for example, if the toolbox
% cache is out-of-date and the file actually no longer is on disc).
function openEditor(file)
% OPENEDITOR  Open file in user specified editor

errMessage = '';
errID = '';

if nargin == 1
  	checkEndsWithBadExtension(file);
    checkFileSize(file);   
end    
        
% Try to open the Editor
try
    if nargin==0
        createUntitled();
    else
        createOrOpenFile(file);
    end % if nargin
catch exception %#ok
    % Failed. Bail
    errMessage = ['Failed to open editor. Load of Java classes failed: ' getReport(exception)];
    errID = 'JavaErr';
end
handleError(errMessage, errID);

%--------------------------------------------------------------------------
% Helper function that trims spaces from a string.  Taken from the original
% edit.m
function s1 = strtrim(s)
%STRTRIM Trim spaces from string.

if isempty(s)
    s1 = s;
else
    % remove leading and trailing blanks (including nulls)
    c = find(s ~= ' ' & s ~= 0);
    s1 = s(min(c):max(c));
end

%----------------------------------------------------------------------------
% Checks if filename is valid by platform.  Also checks for valid m-file names.
function checkValidName(file)
% Is this a valid filename?

[pathname,name,ext] = fileparts(file); 
ext = lower(ext);

if strcmp(ext, '.m')
    % MATLAB names must start with a letter and contain only letters, numbers and underscores.
    % isvarname also checks that name is not a keyword and does not exceed max name length
    if ~isvarname(name)
        errMessage = sprintf('File ''%s'' contains invalid characters.', file);
        errID = 'BadChars';
        handleError(errMessage, errID);    
    end
end

if ~isunix
    invalid = '/\:*"?<>|';
    a = strtok(file,invalid);

    if ~strcmp(a, file)
        errMessage = sprintf('File ''%s'' contains invalid characters.', file);
        errID = 'BadChars';
        handleError(errMessage, errID);
    end
end

%--------------------------------------------------------------------------
% Helper method that tries to resolve argName with the path.
% If it does, it opens the file.
function fExists = openPath(argName)

[fExists, pathName] = resolvePath(argName);

if (fExists)
    openEditor(pathName);
end

%--------------------------------------------------------------------------
% Helper method that resolves using the path
function [result, absPathname] = resolvePath(argName)

result = 0;
absPathname = argName;

% Logic to call correct help functions that moved from helpUtils. to
% matlab.internal.language.introspective in r2014b.
% g1042034

if ~isempty(which('matlab.internal.language.introspective.separateImplicitDirs'))
    [~ , relativePath] = matlab.internal.language.introspective.separateImplicitDirs(pwd);
else
    [~ , relativePath] = helpUtils.separateImplicitDirs(pwd);
end

if ~isempty(which('matlab.internal.language.introspective.resolveName'))
    classResolver = matlab.internal.language.introspective.resolveName(argName, relativePath, false);
    classInfo     = classResolver.classInfo;
    whichTopic    = classResolver.nameLocation;    
elseif ~isempty(which('matlab.internal.language.introspective.splitClassInformation'))
    [classInfo, whichTopic] = matlab.internal.language.introspective.splitClassInformation(argName, relativePath, false);
else
    [classInfo, whichTopic] = helpUtils.splitClassInformation(argName, relativePath, false);
end

if ~isempty(whichTopic)
    % whichTopic is the full path to the resolved output either by class 
    % inference or by which

    switch exist(whichTopic, 'file')
        case {0, 3} % MEX File
            % Do not error, instead behave as if no file was found
            return;
        case 4 % Mdl File
            if ~hasExtension(argName)
                error(message('MATLAB:Editor:MdlErr', argName));
            end
        case 6 % P File
            if ~hasExtension(argName)
                % see if a corresponding M file exists
                whichTopic(end) = 'm';
                if ~exist(whichTopic, 'file')
                    % put the P back for a good error message
                    whichTopic(end) = 'p';
                end
            end
        case 7 % Directory, therefore package
            error(message('MATLAB:Editor:PkgErr', classInfo.fullTopic));
    end

    result = 1;

    if isAbsolutePath(whichTopic)
        absPathname = whichTopic;
    else
        absPathname = which(whichTopic);
    end
end

%--------------------------------------------------------------------------
% Helper method that tries to resolve argName as a builtin operator.
% If it does, it opens the file.
function fExists = openOperator(argName)

[fExists, pathName] = resolveOperator(argName);

if (fExists)
    openEditor(pathName);
end

%--------------------------------------------------------------------------
% Helper method that resolves builtin operators
function [result, absPathname] = resolveOperator(argName)
if isempty(which('matlab.internal.language.introspective.isOperator'))
    isOperatorResult = helpUtils.isOperator(argName);
else
    isOperatorResult = matlab.internal.language.introspective.isOperator(argName);
end
if isOperatorResult && exist(argName, 'builtin')
    argName = regexp(which(argName), '\w+(?=\.[mp]$|\)$|$)', 'match', 'once');
    absPathname = which([argName '.m']);
    result = 1;
else
    result = 0;
    absPathname = argName;
end

%--------------------------------------------------------------------------
% Helper method that tries to resolve argName as a file.
% If it does, it opens the file.
function fExists = openWithFileSystem(argName, errorDir)

[fExists, pathName] = resolveWithFileSystem(argName, errorDir);

if (fExists)
    openEditor(pathName);
end

%--------------------------------------------------------------------------
% Helper method that checks the filesystem for files
function [result, absPathname] = resolveWithFileSystem(argName, errorDir)
[result, absPathname] = resolveWithDir(argName, errorDir);

if ~result && ~hasExtension(argName)
    argM = [argName '.m'];
    [result, absPathname] = resolveWithDir(argM, false);
end


%--------------------------------------------------------------------------
% Helper method that checks the filesystem for files
function [result, absPathname] = resolveWithDir(argName, errorDir)
    
result = 0;
absPathname = argName;

dir_result = dir(argName);

if ~isempty(dir_result)
    if (numel(dir_result) == 1) && ~dir_result.isdir
        result = 1;  % File exists
        % If file exists in the current directory, return absolute path
        if (~isAbsolutePath(argName))
            absPathname = fullfile(pwd, argName);
        end
    elseif errorDir
        errMessage = sprintf('Can''t edit the directory ''%s''.', argName);
        errID = 'BadDir';
        handleError(errMessage, errID);
    end
end

%--------------------------------------------------------------------------
% Translates a path like '~/myfile.m' into '/home/username/myfile.m'.
% Will only translate on Unix.
function pathname = translateUserHomeDirectory(pathname)
if isunix && strncmp(pathname, '~/', 2)
    pathname = [deblank(evalc('!echo $HOME')) pathname(2:end)];
end

%--------------------------------------------------------------------------
% Helper method that determines if filename specified has an extension.
% Returns true if filename does have an extension, false otherwise
function result = hasExtension(s)

[pathname,name,ext] = fileparts(s);
if (isempty(ext))
    result = false;
    return;
end
result = true;


%----------------------------------------------------------------------------
% Helper method that returns error message for file not found
%
function [errMessage, errID] = showFileNotFound(file, rehashToolbox)

if hasExtension(file) % we did not change the original argument
    errMessage = sprintf('File ''%s'' not found.', file);
    errID = 'FileNotFound';
else % we couldn't find original argument, so we also tried modifying the name
    errMessage = sprintf('Neither ''%1$s'' nor ''%1$s.m'' could be found.', file);
    errID = 'FilesNotFound';
end

if (rehashToolbox) % reset errMessage to rehash message
    errMessage = sprintf('File ''%s''\nis on your MATLAB path but cannot be found.\nVerify that your toolbox cache is up-to-date.', file);
end

%--------------------------------------------------------------------------
% Helper method that checks if filename specified ends in .mex or .p.
% For mex, actually checks if extension BEGINS with .mex to cover different forms.
% If any of those bad cases are true, throws an error message.
function checkEndsWithBadExtension(s)

errMessage = '';
errID = '';

[pathname,name,ext] = fileparts(s); 
ext = lower(ext);

if (~strcmp(ext, '') && ~strcmp(ext, '.m') && ~strcmp(ext, '.txt') )
    errMessage = sprintf('File type is not supported for this product offering.  See the MATLAB Mobile documentation for more information.');
    errID = 'BadExtensionFile';
end
handleError(errMessage, errID);


%--------------------------------------------------------------------------
% Helper method that checks if file size is too big. 
% For now, we think size bigger than 300Kb is going to affect the user's experience on mobile devices.  It takes about 1 min to
% load on the Android devices.
function checkFileSize(s)

errMessage = '';
errID = '';
size = 0;

if ~isempty(which(s)) %if file exists
    filepath = which(s); %this is the full file path including file name.
    myFile = java.io.File(filepath);
    size = length(myFile);
end
if (size > 307200)     %Currently, 300KB is the limit for mobile.
    errMessage = sprintf('File is too large for this product offering. See the MATLAB Mobile documentation for more information.');
    errID = 'FileSizeTooLarge';
    handleError(errMessage, errID);
end

%--------------------------------------------------------------------------
function handleError(errMessage, errID)
if (~isempty(errMessage))
    error(makeErrID(errID), '%s', errMessage);
end

%--------------------------------------------------------------------------
% Helper method that checks for directory seps.
function result = isSimpleFile(file)

result = false;
if isunix
    if isempty(findstr(file, '/'))
        result = true;
    end
else % on windows be more restrictive
    if isempty(findstr(file, '\')) && isempty(findstr(file, '/'))...
            && isempty(findstr(file, ':')) % need to keep : for c: case
        result = true;
    end
end

%--------------------------------------------------------------------------
% Helper method for error messageID display
function realErrID = makeErrID(errIDin)
realErrID = ['MATLABeditor:'  errIDin];

%--------------------------------------------------------------------------
function result = isAbsolutePath(filePath)
% Helper method to determine if the given path to an existing file is
% absolute.
% NOTE: the given filePath is assumed to exist.

    result = false;
    [directoryPart, filePart] = fileparts(filePath); %#ok<NASGU>
    
    if isunix && strncmp(directoryPart, '/', 1)
        result = true;
    elseif ispc && ... % Match C:\, C:/, \\, and // as absolute paths
            (~isempty(regexp(directoryPart, '^([\w]:[\\/]|\\\\|//)', 'once')))
        result = true;
    end
