%FUNC2STR Construct a function name from a function handle.
%    C = FUNC2STR(FUNHANDLE) returns a character vector C that represents 
%    FUNHANDLE.  If FUNHANDLE is a function handle to an anonymous function,
%    C contains the text that defines that function.  If FUNHANDLE is a
%    function handle to a named function, C contains the name of that function.
% 
%    When you need to perform a character vector operation, such as compare
%    or display, on a function handle, you can use FUNC2STR to construct a
%    character vector representing the function.
%
%    Examples:
%
%      To create a character vector containing the function name from the
%      function handle, @humps:
%
%        funname = func2str(@humps)
%        funname =
%        humps
%
%      To create a character vector representation of an anonymous function:
%
%        anontext = func2str(@(x)x/3)
%        anontext =
%        @(x)x/3
%
%    See also FUNCTION_HANDLE, STR2FUNC, FUNCTIONS.

%   Copyright 1984-2016 The MathWorks, Inc.

