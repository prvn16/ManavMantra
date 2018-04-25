%FUNCTIONS Return information about a function handle.
%    F = FUNCTIONS(FUNHANDLE) returns, in a MATLAB structure, the function
%    name, type, and other information about FUNHANDLE.  
%
%    The FUNCTIONS function is used for internal purposes, and is provided
%    for querying and debugging purposes.  Its behavior may change in
%    subsequent releases, so it should not be relied upon for programming
%    purposes.
%
%    Examples:
%
%      To get information on a function handle for the POLY function, type
%
%      f = functions(@poly)
%      f = 
%          function: 'poly'
%              type: 'simple'
%              file: '$matlabroot\toolbox\matlab\polyfun\poly.m'
%
%      (The term $matlabroot used in this example stands for the directory 
%      in which MATLAB software is installed for your system.)
%
%    See also FUNCTION_HANDLE, FUNC2STR, STR2FUNC.

%   Copyright 1984-2005 The MathWorks, Inc.
%   Built-in functions.

