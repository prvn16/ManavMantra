function [status, msg] = regmatlabserver(varargin)

%REGMATLABSERVER Register current MATLAB as an automation server.
%   REGMATLABSERVER registers the current MATLAB executable as an automation
%   server.
%
%   [STATUS, MESSAGE] = REGMATLABSERVER additionally returns the status
%   and message reported by DOS. When called with output arguments, if the
%   system call fails to register the MATLAB server, STATUS will be 
%   non-zero, and MESSAGE will contain the system error message.

% Copyright 2006-2011 The MathWorks, Inc.

% Windows only
if ~ispc
    error(message('MATLAB:regmatlabserver:NonPC'));
end


if (nargin > 1)
    error(message('MATLAB:regmatlabserver:BadArgs'));
end

runAsAdmin = '';
if (nargin == 1)
	runAsAdmin = varargin{1};
end

% Form command
command = sprintf('"%s" /wait /regserver /r quit', ...
          fullfile(matlabroot,'bin','matlab'));

% Run command and capture output
[s,msg] = system(command, runAsAdmin);

% If status/message was requested, simply return them.
% Otherwise, throw an error
if nargout>0
    status = s;
elseif s~=0
    error(message('MATLAB:regmatlabserver:DosError',command,s,msg));
end

