%STR2FUNC Construct a function_handle from a function name.
%    FUNHANDLE = STR2FUNC(S) constructs a function_handle FUNHANDLE to the
%    function named in S. The S input must be a string scalar or
%    character vector. 
%
%    You can create a function handle using either the @function syntax or
%    the STR2FUNC command. You can create an array of function handles by 
%    creating the handles individually with STR2FUNC, and then storing 
%    these handles in a cell array.
%
%    Examples:
%
%      To create a function handle from the function name, 'humps':
%
%        fhandle = str2func('humps')
%        fhandle = 
%            @humps
%
%      To call STR2FUNC on a cell array of character vectors, use the
%      CELLFUN function. This returns a cell array of function handles:
%
%        fh_array = cellfun(@str2func, {'sin' 'cos' 'tan'}, ...
%                           'UniformOutput', false);
%        fh_array{2}(5)
%        ans =
%           0.2837
%
%    See also FUNCTION_HANDLE, FUNC2STR, FUNCTIONS.

%   Copyright 1984-2017 The MathWorks, Inc.

