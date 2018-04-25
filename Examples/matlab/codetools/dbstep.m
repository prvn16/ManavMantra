%DBSTEP Execute one or more lines from current breakpoint
%   The DBSTEP command allows the user to execute one or more lines of
%   executable MATLAB code and upon their completion revert back to the
%   debug mode.  There are four forms to this command.  They are:
%
%   DBSTEP
%   DBSTEP nlines
%   DBSTEP IN
%   DBSTEP OUT
%
%   where nlines is the number of executable lines to step.
%   The first form causes the execution of the next executable line.
%   The second form causes the execution of the next nlines executable
%   lines.  When the next executable line is a call to another 
%   function or script, the third form allows the user to step to the first 
%   executable line in the called file.  The fourth form runs the rest of 
%   the function and stops just after leaving the function. For all forms, 
%   MATLAB also stops execution at any breakpoint it encounters.
%
%   See also DBCONT, DBSTOP, DBCLEAR, DBTYPE, DBSTACK, DBUP, DBDOWN,
%            DBSTATUS, DBQUIT.

%   Copyright 1984-2011 The MathWorks, Inc.
%   Built-in function.

