%DBTYPE Display program file with line numbers
%   The DBTYPE function displays the contents of a MATLAB program file with
%   line numbers to aid the user in setting breakpoints.  There are two
%   forms to this command.  They are:
%
%   DBTYPE FILE
%   DBTYPE FILE RANGE
%
%   DBTYPE FILE displays the contents of FILE. FILE can include a partial
%   pathname (see PARTIALPATH), and is specified as a character vector or
%   string scalar.
%
%   DBTYPE FILE RANGE displays those lines of the program file that 
%   are within the specified RANGE of line numbers. The RANGE input
%   consists of a starting line number, followed by a colon, followed by 
%   an ending line number, as shown here:
%
%      dbtype myfun.m 10:24    % Display lines 10 through 24 of myfun.m.
%

%   See also DBSTEP, DBSTOP, DBCONT, DBCLEAR, DBSTACK, DBUP, DBDOWN,
%            DBSTATUS, DBQUIT, PARTIALPATH, TYPE.

%   Copyright 1984-2017 The MathWorks, Inc.
%   Built-in function.

