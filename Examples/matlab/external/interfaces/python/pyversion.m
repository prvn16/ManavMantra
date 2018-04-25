%PYVERSION Change default version of Python interpreter
%
%   PYVERSION displays details about the current Python version. 
%
%   PYVERSION(VERSION) changes the default Python version on Microsoft 
%   Windows platforms. The setting is persistent across MATLAB sessions. 
%   You cannot change the version after MATLAB loads Python, which happens 
%   when you type any py. command. Use isloaded to determine the status. To 
%   change the version if Python is loaded already, restart MATLAB, and 
%   then call pyversion.
%
%   PYVERSION(EXECUTABLE) specifies full path to Python executable. Use on 
%   any platform or for repackaged CPython implementation downloads.
%
%   [VERSION, EXECUTABLE, ISLOADED] = PYVERSION(__) returns Python version 
%   information. 
%
%   Examples
%
%   % display Python version 
%   pyversion 
%
%   % use Python version 2.7 
%   [v, e, loaded] = pyversion;
%   if loaded
%       disp('To change the Python version, restart MATLAB, then call pyversion.')
%   else
%       pyversion 2.7
%   end

% Copyright 2014 The MathWorks, Inc.

