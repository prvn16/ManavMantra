%DBQUIT Quit debug mode
%   DBQUIT terminates debug mode. The Command Window then displays the
%   standard prompt (>>). The file being executed is not completed and
%   no results are returned. All breakpoints remain in effect.
%   
%   If MATLAB is in debug mode for more than one function, DBQUIT
%   terminates debugging for the function at which MATLAB is currently
%   stopped, and control moves to another function being debugged.
%
%   DBQUIT('all') ends debugging for all files at once.
%   
%   See also DBSTOP, DBCONT, DBSTEP, DBCLEAR, DBTYPE, DBSTACK, DBUP,
%   DBDOWN, and DBSTATUS.

%   Copyright 1984-2011 The MathWorks, Inc.
%   Built-in function.

