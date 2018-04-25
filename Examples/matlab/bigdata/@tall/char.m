function s = char(x, varargin)
%CHAR Create character array (string).
%   S = CHAR(X)
%
%   Restrictions:
%   X must be a tall numeric column vector.
%
%   Use CELLSTR to convert tall arrays of datetime to tall cell arrays of
%   character vectors.
%
%   See also char, tall/cellstr, tall.

% Copyright 2016 The MathWorks, Inc.

% We do not support the multiple input syntax for converting multiple char
% vectors into a char matrix.
if nargin > 1
    error(message('MATLAB:bigdata:array:CharMultipleInputsNotSupported'));
end

% Because we want to throw several different errors here, we can't use the
% normal lazyValidate pattern.
s = elementfun(@iCharWithCheck, x);
s = setKnownType(s, 'char');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = iCharWithCheck(in)
if isdatetime(in) || isduration(in) || iscalendarduration(in) ...
        || iscategorical(in) || isstring(in)
    error(message('MATLAB:bigdata:array:CharUseCellstr', class(in)));
elseif ~isnumeric(in) || ~iscolumn(in)
    error(message('MATLAB:bigdata:array:CharNumericColumn'));
end
out = char(in);
end
