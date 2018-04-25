function run(scriptname)
%RUN Run script.
%   Typically, you just type the name of a script at the prompt to
%   execute it. This works when the script is on your path.  Use CD
%   or ADDPATH to make the script executable from the prompt.
%
%   RUN is a convenience function that runs scripts that are not
%   currently on the path.
%
%   RUN SCRIPTNAME runs the specified script. If SCRIPTNAME contains
%   the full pathname to the script, then RUN changes the current
%   directory to where the script lives, executes the script, and then
%   changes back to the original starting point. The script is run
%   within the caller's workspace.
%

%   NOTES:
%     * If SCRIPTNAME attempts to CD into its own folder, RUN cannot detect
%       this change. In this case, RUN will revert to the starting folder
%       on exit.
%     * If SCRIPTNAME is a MATLAB file and there is a P-file in the same
%       folder, RUN silently executes the P-file.
%
%   See also CD, ADDPATH.

%   Copyright 1984-2017 The MathWorks, Inc.

if isempty(scriptname)
    return;
end

if isstring(scriptname)
    scriptname = char(scriptname);
end

if ispc
    scriptname = strrep(scriptname,'/','\');
end
cleaner = onCleanup(@() ([]));
[fileDir,script,ext] = fileparts(scriptname);
startDir = pwd;

% If the input had a path, CD to that path if it exists
if ~isempty(fileDir)
    if ~exist(fileDir,'dir')
        error(message('MATLAB:run:FileNotFound',scriptname));
    end
    cd(fileDir);
    
    fileDir = pwd; % get the fully qualified path name
    cleaner = onCleanup(@() resetCD(startDir,fileDir));
end

% Look for executable 'script', ignoring variables in RUN's workspace.
pathscript = evalin('caller', strcat('which(''', script, ''')'));

%if it is a variable then 'script' cannot be run due to precedence
if strcmp(pathscript, 'variable')
    warning(message('MATLAB:persistentVariableAlreadyInWS', script));
    return;
end

% If not found .
if isempty(pathscript)  
    if isempty(fileDir) || isempty(ext)
        error(message('MATLAB:run:FileNotFound',scriptname));
    else
        error(message('MATLAB:run:CannotExecute',scriptname));
    end
end

[runDir,~,rext] = fileparts(pathscript);

%If which doesn't find a script in the same location as the requested path,
% calling evalin will run the wrong script.
% In other words, the script at the requested path doesn't exist.
if isempty(runDir) || (~isempty(fileDir) && ~strcmp(runDir,pwd))
    error(message('MATLAB:run:FileNotFound',scriptname));
end

% If an extension was given, and doesn't match the results of which -all, 
% then do not try to run the script--it is the wrong thing--except when 
% both a .m and .p file exist with the same name.
if ~isempty(ext) ...
    && ~strcmp(ext,rext)...
    && ~(strcmp(ext,'.m') && strcmp(rext,'.p'))
    error(message('MATLAB:run:CannotExecute',scriptname));
end

% Finally, evaluate the script if it exists and isn't a shadowed script.
evalin('caller', strcat(script, ';'));
delete(cleaner);
end

%on exit in case of an error.
function resetCD(returnDir,tempDir)
if strcmp(tempDir,pwd)
    cd(returnDir);
end
end
