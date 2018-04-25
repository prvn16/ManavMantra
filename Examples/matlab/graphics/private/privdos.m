function [status, result, wdir] = privdos( varargin )
%PRIVDOS - internal helper function 
 
% Execute DOS command in save current directory and return result.
%   Uses built-in DOS command after changing the current directory to
%   one that is not a UNC path or nested too deeply to work reliably.
%
%   See also DOS.

%   Copyright 1984-2017 The MathWorks, Inc.

if ~strncmp(computer,'PC',2)
    error(message('MATLAB:print:WrongPlatform'))
end
wdir = '';

wasErr = 0;
try
    %Check to see if cwd is going to be a problem.
    %UNC test is new (DOS doesn't work on UNC path), CD test is from Jason:
    %If cwd is bad, move to what is considered the temporary directory
    %or c:\ if tempdir is itself a UNC directory.
    if strncmp(tempdir, '\\', 2)
        tdir = 'c:\';
    else
        tdir = tempdir;
    end
    OldDir = pwd;
    if strncmp( OldDir, '\\', 2 ) %i.e. path starts with \\
        cd(tdir)
        wdir = tdir; % we're changing our working directory; caller may need to know
    else
        % This is to check and see if the dos command is working.  In Win95
        % if the current directory is a deeply nested directory or sometimes
        % for TAS served file systems, the output pipe does not work.  The 
        % solution is to make the current directory safe, C:\ and put it back
        % when we are done.  The test is the cd command, which should always
        % return something.
	try
	  [status, result] = dos('cd');
    catch ex
	  result = '';
	end
        if isempty(result)
            cd(tdir)
            wdir = tdir; % we're changing our working directory; caller may need to know
        else
            OldDir = [];
        end
    end

    %Execute the given DOS command.
    try
      [status, result] = dos(varargin{2:end});
    catch ex
      % Try dos with one output if last command fails.
      status = dos(varargin{2:end});
      result = '';
    end
catch ex
    wasErr = 1;
end

%Move back if necessary.
if ~isempty(OldDir)
    cd(OldDir);
end

if wasErr
    error(ex)
end

