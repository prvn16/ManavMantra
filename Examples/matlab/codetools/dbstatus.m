%DBSTATUS List all breakpoints
%   DBSTATUS, by itself, displays a list of all the breakpoints the debugger
%   knows about including ERROR, CAUGHT ERROR, WARNING, and NANINF.
%
%   DBSTATUS FILE displays the breakpoints set in FILE. FILE can include a 
%   partial pathname (see PARTIALPATH), and is specified as a character
%   vector or string scalar.
%
%   DBSTATUS('-completenames') outputs the "complete name" of each function.
%   A complete name includes the absolute file name and the entire sequence of
%   functions that nest the function in which a breakpoint is set.
%
%   S = DBSTATUS(...) returns the breakpoint information in an M-by-1
%   structure with the fields:
%       name -- function name.
%       file -- full name of the file containing breakpoint(s).
%       line -- vector of breakpoint line numbers.
%       anonymous -- integer vector, each element of which corresponds to an
%                    element of the 'line' field.  Each positive element
%                    represents a breakpoint in the body of an anonymous
%                    function on that line.  For example, a breakpoint in the
%                    body of the second anonymous function on the line results
%                    in the value 2 in this vector.  If an element is 0, the
%                    breakpoint is at the beginning of the line, i.e., not in
%                    an anonymous function.
%       expression -- cell vector of breakpoint conditional expressions
%                     corresponding to lines in the 'line' field.
%       cond -- condition ('error', 'caught error', 'warning', or 
%               'naninf').
%       identifier -- when cond is 'error', 'caught error', or 'warning', 
%                     a cell vector of MATLAB Message Identifiers
%                     for which the particular cond state is set.
%
%   See also DBSTEP, DBSTOP, DBCONT, DBCLEAR, DBTYPE, DBSTACK, DBUP, DBDOWN,
%            DBQUIT, ERROR, PARTIALPATH, WARNING.

%   Copyright 1984-2017 The MathWorks, Inc.
%   Built-in function.

