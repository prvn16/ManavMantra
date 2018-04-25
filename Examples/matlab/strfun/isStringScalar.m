function tf = isStringScalar(s)
%isStringScalar Determine whether input is a string array with one element
%   isStringScalar(S) returns 1 (true) if S is a string scalar and 0
%   (false) otherwise.  This is equivalent to:
%
%                   isstring(S) && isscalar(S)
%
%   Examples:
%       isStringScalar("Smith")                       % returns 1
%
%       isStringScalar('Mary Jones')                  % returns 0
%
%       isStringScalar(["Smith","Burns","Jones"])     % returns 0
%
%   See also STRING, ISSTRING, ISSCALAR, ISCHAR, ISCELLSTR,
%   convertCharsToStrings, convertStringsToChars.

%   Copyright 2017 The MathWorks, Inc.
%#codegen

narginchk(1,1);

tf = isstring(s) && isscalar(s);

end
