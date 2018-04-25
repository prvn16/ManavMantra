function foundFile = edit(varargin)
%EDIT Edit or create a file
%   EDIT FUN opens the file FUN.M in a text editor.  FUN must be the
%   name of a file with a .m extension or a MATLABPATH relative 
%   partial pathname (see PARTIALPATH).
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
%   By default, the MATLAB built-in editor is used.  The user may
%   specify a different editor by modifying the Editor/Debugger
%   Preferences.
%
%   If the specified file does not exist and the user is using the
%   MATLAB built-in editor, an empty file may be opened depending on
%   the Editor/Debugger Preferences.  If the user has specified a
%   different editor, the name of the non-existent file will always
%   be passed to the other editor.

%   Copyright 1984-2017 The MathWorks, Inc.


if ~iscellstr(varargin) && ~isstring(varargin) && ...
        ~all(cellfun(@(x)istextscalar(x),varargin))
    error(message('MATLAB:Editor:NotString'));
end
varargin = cellstr(varargin);

if nargout
    foundFile = true;
end

try
    if (nargin == 0)
        openEditor;
    else
        for i = 1:nargin
            argName = translateUserHomeDirectory(strtrim(varargin{i}));
            if isempty(argName)
                openEditor;
            elseif ~openInPrivateOfCallingFile(argName)
                if ~openOperator(argName)
                    if ~openWithFileSystem(argName, ~isSimpleFile(argName))
                        if ~openPath(argName)
                            if nargout
                                foundFile = false;
                            else
                                showEmptyFile(argName);
                            end
                        end
                    end
                end
            end
        end
    end
catch exception
    if nargout
        foundFile = false;
    else
        throw(exception); % throw so that we don't display stack trace
    end
end

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
    if ~opened
        opened = openWithFileSystemAndExts(privateName);
    end
end

%--------------------------------------------------------------------------
% Helper function that displays an empty file -- taken from the previous edit.m
% Now passes error message to main function for display through error.
function showEmptyFile(file)

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
    
    if (isempty(checkJavaAvailable) ...
            && com.mathworks.mde.editor.EditorOptions.getShowNewFilePrompt == false ...
            && com.mathworks.mde.editor.EditorOptions.getNamedBufferOption == ...
                com.mathworks.mde.editor.EditorOptions.NAMEDBUFFER_DONTCREATE ...
            && com.mathworks.mde.editor.EditorOptions.getBuiltinEditor ~= 0)
        showFileNotFound(file);
    else
        openEditor(fullfile(path,fileName));
    end
else
    showFileNotFound(file);
end

%--------------------------------------------------------------------------
% Retrieve value from settings
function result = isUsingBuiltinEditor
% g1609199 - Retrieve the preference value using the Settings API. 
s = matlab.settings.internal.settings;
result = s.matlab.editor.UseMATLABEditor.ActiveValue;

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
if ~usejava('swing')
    result = message('MATLAB:Editor:NotSupported');
else
    result = '';
end

 
%--------------------------------------------------------------------------
% Helper function that calls the java editor.  Taken from the original edit.m.
% Did modify to pass non-existent files to outside editors if
% user has chosen not to use the built-in editor.
% Also now passing out all error messages for proper display through error.
% It is possible that this is incorrect (for example, if the toolbox
% cache is out-of-date and the file actually no longer is on disc).
function openEditor(file, localFunctionName)
% OPENEDITOR  Open file in user specified editor

if nargin
    checkEndsWithBadExtension(file);
end

if (nargin >= 1) && hasFileTypeEditor(file)
    fileTypeEditor = getFileTypeEditor(file);
    if nargin == 1
        feval(fileTypeEditor, file);
        return
    else
        feval(fileTypeEditor, file, localFunctionName);
        return
    end
end
    
% Make sure our environment supports the editor. Need java.
err = checkJavaAvailable;
if ~isempty(err)
    if isunix % unix includes Mac
        if nargin==0 % nargin = 0 means no file specified at all.  This case is ok.
            if isMac
                openFileOnMac(getenv('EDITOR'));
            else
                system_dependent('miedit', '');
            end
        else
            if isMac
                openFileOnMac(getenv('EDITOR'), file);
            else
                system_dependent('miedit', file);
            end
        end
        return
    end
end

if isUsingBuiltinEditor
    % Swing isn't available, so return with error
    if ~isempty(err)
        error(err);
    else
        % Try to open the Editor
        try
            if nargin==0
                matlab.desktop.editor.newDocument;
            elseif nargin > 1 && ~isempty(localFunctionName)
                matlab.desktop.editor.openAndGoToFunction(file, localFunctionName);
            else
                % Don't call matlab.desktop.editor.openDocument because it
                % does not prompt for files that don't exist.
                matlab.desktop.editor.Document.openEditor(file);
            end % if nargin
        catch exception
            genericMessage = MException(message('MATLAB:Editor:EditorInstantiationFailure'));
            throw(addCause(genericMessage, exception));         
        end
    end
else
    % User-specified editor
    if nargin == 0
        openExternalEditor;
    else
        openExternalEditor(file);
    end
end

%--------------------------------------------------------------------------
% Open the user's external editor
function openExternalEditor(file)
editor = getOtherEditor;

if ispc
    % On Windows, we need to wrap the editor command in double quotes
    % in case it contains spaces
    if nargin == 0
        system(['"' editor '" &']);
    else
        system(['"' editor '" "' file '" &']);
    end
elseif isunix && ~isMac
    % Special case for vi and vim
    if strcmp(editor,'vi') == 1 || strcmp(editor,'vim') == 1
        editor = ['xterm -e ' editor];
    end

    % On UNIX, we don't want to use quotes in case the user's editor
    % command contains arguments (like "xterm -e vi")
    if nargin == 0
        system([editor ' &']);
    else
        system([editor ' "' file '" &']);
    end
else
    % Run on Macintosh
    if nargin == 0
        openFileOnMac(editor)
    else
        openFileOnMac(editor, file);
    end
end

%--------------------------------------------------------------------------
% Helper function to see if something is Mac.
function mac = isMac
mac = strncmp(computer,'MAC',3);

%--------------------------------------------------------------------------
% Helper method to run an external editor from the Mac
function openFileOnMac(applicationName, absPath)

% Put app name in quotes
appInQuotes = ['"' applicationName '"'];

% Is this a .app -style application, or a BSD executable?
% If the former, use it to open the file (if any) via the
% BSD OPEN command.
if length(applicationName) > 4 && strcmp(applicationName(end-3:end), '.app')
    % Make sure that the .app actually exists.
    if exist(applicationName, 'dir') ~= 7
        error(message('MATLAB:Editor:ExternalEditorNotFound', applicationName));
    end
    if nargin == 1 || isempty(absPath)
        unix(['open -a ' appInQuotes]);
    else
        unix(['open -a ' appInQuotes ' "' absPath '"']);
    end
    return;
end

% At this point, it must be BSD a executable (or possibly nonexistent)
% Can we find it?
[status, result] = unix(['which ' appInQuotes ]);

% UNIX found the application
if status == 0
    % Special case for vi, vim and emacs since they need a shell
    if checkMacApp(applicationName, 'vi') || ...
            checkMacApp(applicationName, 'vim') || ...
            checkMacApp(applicationName, 'emacs')
        appInQuotes = ['xterm -e ' appInQuotes];
    end
    
    if nargin == 1 || isempty(absPath)
        command = [appInQuotes ' &'];
    else
        command = [appInQuotes ' "' absPath '" &'];
    end

    % We think that we have constructed a viable command.  Execute it,
    % and error if it fails.
    [status, result] = unix(command);
    if status ~= 0
        error(message('MATLAB:Editor:ExternalEditorFailure', result));
    end
    return;
else
    % We could not find a BSD executable.  Error.
    error(message('MATLAB:Editor:ExternalEditorNotFound', result));
end

% Helper function for openFileOnMac
function found = checkMacApp(applicationName, lookFor)
found = contains(applicationName,['/' lookFor]) || ...
    strcmp(applicationName, lookFor) == 1;
        
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
% Checks if filename is valid by platform.
function checkValidName(file)
% Is this a valid filename?
if ~isunix
    invalid = '/\:*"?<>|';
    a = strtok(file,invalid);

    if ~strcmp(a, file)
        error(message('MATLAB:Editor:BadChars', file));
    end
end

%--------------------------------------------------------------------------
% Helper method that tries to resolve argName with the path.
% If it does, it opens the file.
function fExists = openPath(argName)

[fExists, pathName, localFunctionName] = resolvePath(argName);

if (fExists)
    openEditor(pathName, localFunctionName);
end

%--------------------------------------------------------------------------
% Helper method that resolves using the path
function [result, absPathname, localFunctionName] = resolvePath(argName)

[~, relativePath] = matlab.internal.language.introspective.separateImplicitDirs(pwd);

[argName, hasLocalFunction, result, ~, absPathname] = matlab.internal.language.introspective.fixLocalFunctionCase(argName, relativePath);

if hasLocalFunction
    if result && absPathname(end) == 'p'
        % see if a corresponding M file exists
        absPathname(end) = 'm';
        if ~exist(absPathname, 'file')
            % Do not error, instead behave as if no file was found
            result = 0;  
            return;                    
        end        
    end
    localFunctionName = regexp(argName, ['(?<=' filemarker ')\w*$'], 'match', 'once');
else
    localFunctionName = '';
    
    classResolver = matlab.internal.language.introspective.resolveName(argName, relativePath, false);
    
    classInfo     = classResolver.classInfo;
    whichTopic    = classResolver.nameLocation;
    
    if isempty(whichTopic)
        [result, absPathname] = resolveWithFileSystemAndExts(argName);
    else
        % whichTopic is the full path to the resolved output either by class 
        % inference or by which

        switch exist(whichTopic, 'file')
        case 0 % Name resolver found something which is not a file
            assert(~isempty(classInfo));
            whichTopic = classInfo.definition;
        case 3 % MEX File 
            % Do not error, instead behave as if no file was found
            return;
        case {4,6} % P File or Simulink Model
            if ~extensionMatches(whichTopic, argName)
                % see if a corresponding M file exists
                mTopic = regexprep(whichTopic, '\.\w+$', '.m');
                if exist(mTopic, 'file')
                    whichTopic = mTopic;
                elseif ~isempty(regexp(whichTopic, '\.mdl$', 'once'))
                    error(message('MATLAB:Editor:MdlErr', argName));            
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

        if ~isempty(classInfo) && classInfo.isMethod && any(classInfo.definition==filemarker)
            localFunctionName = classInfo.element;
        end
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
    
[isPunctuation, absPathname] = matlab.internal.language.introspective.isOperator(argName);
result = isPunctuation && ~strcmp(absPathname, argName);

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

%--------------------------------------------------------------------------
% Helper method that tries to resolve argName as a file.
% If it does, it opens the file. by adding m or mlx
function fExists = openWithFileSystemAndExts(argName)

[fExists, pathName] = resolveWithFileSystemAndExts(argName);

if (fExists)
    openEditor(pathName);
end

%--------------------------------------------------------------------------
% Helper method that checks the filesystem for files by adding m or mlx
function [result, absPathname] = resolveWithFileSystemAndExts(argName)

result = 0;
absPathname = argName;

if ~hasExtension(argName)
    argMlx = [argName '.mlx'];
    [result, absPathname] = resolveWithDir(argMlx, false);

    if ~result
        argM = [argName '.m'];
        [result, absPathname] = resolveWithDir(argM, false);
    end
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
        error(message('MATLAB:Editor:BadDir', argName));
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

[~,~,ext] = fileparts(s);
result = ~isempty(ext);

%--------------------------------------------------------------------------
% Helper method that determines if the second has the same extension as the
% first
function result = extensionMatches(s1,s2)
[~,~,ext] = fileparts(s1);
result = endsWith(s2,ext,'IgnoreCase',true);

%----------------------------------------------------------------------------
% Helper method that shows error message for file not found
%
function showFileNotFound(file)

if hasExtension(file) % we did not change the original argument
    error(message('MATLAB:Editor:FileNotFound', file));
else % we couldn't find original argument, so we also tried modifying the name
    error(message('MATLAB:Editor:FilesNotFound', file, [file '.m']));
end

%--------------------------------------------------------------------------
% Helper method that checks if filename specified ends in .mex, .p, .mdlp,
% .slxp, .sltx, or .slx.
% For mex, actually checks if extension BEGINS with .mex to cover different forms.
% If any of those bad cases are true, throws an error message.
function checkEndsWithBadExtension(s)
[~,~,ext] = fileparts(s);
ext = lower(ext);
if (strcmp(ext, '.p'))
    error(message('MATLAB:Editor:PFile', s));
elseif (strcmp(ext, ['.' mexext]))
    error(message('MATLAB:Editor:MexFile', s));
elseif (strcmp(ext, '.slx'))
    error(message('MATLAB:Editor:SlxFile', s));
elseif (strcmp(ext, '.sltx'))
    error(message('MATLAB:Editor:SLTXFile', s));
elseif ((strcmp(ext, '.mdlp')) || (strcmp(ext, '.slxp'))) 
    error(message('MATLAB:Editor:ProtectedModel', s));
end

%--------------------------------------------------------------------------
% Helper method that checks for directory seps.
function result = isSimpleFile(file)

result = false;
if isunix
    if ~contains(file, '/')
        result = true;
    end
else % on windows be more restrictive
    if ~contains(file, ["\", "/", ":"]) % need to keep : for c: case
        result = true;
    end
end

%--------------------------------------------------------------------------
function result = isAbsolutePath(filePath)
% Helper method to determine if the given path to an existing file is
% absolute.
% NOTE: the given filePath is assumed to exist.

    result = false;
    directoryPart = fileparts(filePath);
    
    if isunix && strncmp(directoryPart, '/', 1)
        result = true;
    elseif ispc && ... % Match C:\, C:/, \\, and // as absolute paths
            (~isempty(regexp(directoryPart, '^([\w]:[\\/]|\\\\|//)', 'once')))
        result = true;
    end
    
function hasEditor = hasFileTypeEditor(fileName)
% Helper method to determine if the given file has a file type specific
% editor that should not be handled by the editor.
    if nargin ~= 1
        hasEditor = false;
        return;
    end
    customEditor = getFileTypeEditor(fileName);
    hasEditor = ~isempty(customEditor);
    
    
function customEditor = getFileTypeEditor(fileName)
% Helper method to find a file type specific editor. Looks on the path to
% find a function of the form edit<file extension>.

customEditor = matlab.codetools.internal.getActionForFileType(fileName, 'edit');


function tf = istextscalar(text)
tf = ischar(text) || (isstring(text) && isscalar(text));
