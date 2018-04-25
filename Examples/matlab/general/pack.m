%PACK   Consolidate workspace memory.
%   PACK performs memory garbage collection. Extended MATLAB
%   sessions may cause memory to become fragmented, preventing
%   large variables from being stored. PACK is a command that
%   saves all variables on disk, clears the memory, and then
%   reloads the variables.
%
%   If you run out of memory often, here are some additional system
%   specific tips:
%   Windows:    Increase virtual memory using the control panel.
%   Unix:       Ask your system manager to increase your Swap Space.
%
%   You should cd to a directory where you have "write" permission to execute
%   this command successfully. The following lines of code will help you 
%   accomplish the consolidation of workspace memory.
%
%           cwd = pwd;
%           cd(tempdir);
%           pack
%           cd(cwd)
%
%   See also MEMORY, SAVE, LOAD, CLEAR.

%   Copyright 1984-2005 The MathWorks, Inc.
%   Built-in function.
