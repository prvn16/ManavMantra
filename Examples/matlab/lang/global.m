%GLOBAL Define global variable.
%   GLOBAL X Y Z defines X, Y, and Z as global in scope.
%
%   Ordinarily, each MATLAB function has its
%   own local variables, which are separate from those of other functions,
%   and from those of the base workspace.  However, if several functions, 
%   and possibly the base workspace, all declare a particular name as 
%   GLOBAL, then they all share a single copy of that variable.  Any 
%   assignment to that variable, in any function, is available to all the 
%   other functions declaring it GLOBAL.
%
%   If the global variable doesn't exist the first time you issue
%   the GLOBAL statement, it will be initialized to the empty matrix.
%
%   If a variable with the same name as the global variable already exists
%   in the current workspace, MATLAB issues a warning and changes the
%   value of that variable to match the global.
%
%   Stylistically, global variables often have long names with all
%   capital letters, but this is not required.
%
%   See also CLEAR, CLEARVARS, WHO, PERSISTENT.

%   Copyright 1984-2015 The MathWorks, Inc.
%   Built-in function.
