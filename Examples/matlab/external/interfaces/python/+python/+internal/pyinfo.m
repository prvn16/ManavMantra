function info = pyinfo(executable)
%PYINFO Information about Python environment.
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within the scope of functions and classes
%   in the MATLAB external interface to Python. Its behavior may change, 
%   or the function itself may be removed in a future release.
%
% Description
% 
%    Query Python for the information necessary to initialize an embedded
%    interpreter.
%
% Input Arguments
%
%    executable - absolute path to Python executable
%
% Output Argument
%
%    info - information about the Python executable such as version,
%    executable, home, path and library.
%
% Example
%
%    python.internal.pyinfo('C:\Python33\python.exe')
% 
%     ans = 
% 
%            version: '3.3'
%         executable: 'C:\Python33\python.exe'
%            library: 'C:\windows\system32\python33.dll'
%               home: 'C:\Python33'
%               path: 'C:\windows\system32\python33.zip;C:\Python33\DLLs;C:\Python33\lib;C:\Python33;C:\Python33\lib\site-packages'
%            bitness: '64-Bit'
% 
%

% Copyright 2014-2015 The MathWorks, Inc.

% Compute the name of the Python script based on the path to this M
% function.
script_name = [mfilename('fullpath'), '.py'];

% Invoke the Python script.
[status, out] = system([executable, ' ', script_name]);
if status ~= 0
    error('system call to Python executable ''%s'' failed.', executable);
end

% Parse the output.
lines = strsplit(out);
info = struct('version',    lines{1},...
              'executable', lines{2},...
              'library',    lines{3},...
              'home',       lines{4},...
              'path',       lines{5},...
              'bitness',    lines{6});
end
