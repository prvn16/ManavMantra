function b = sum(a,varargin)
%SUM Sum of durations.
%   S = SUM(T), when T is a vector of durations, returns the sum of the elements
%   of T as a scalar duration S. When T is a matrix, SUM(T) is a row vector
%   containing the sum of each column.  For N-D arrays, SUM(T) is the sum of the
%   elements along the first non-singleton dimension of T.
%   
%   S = SUM(T,DIM) takes the sum along the dimension DIM of T.
%
%   S = SUM(..., MISSING) specifies how NaN (Not-A-Number) values are treated.
%
%      'includenan' - the sum of a vector containing any NaN values is also NaN.
%                     This is the default.
%      'omitnan'    - elements of T containing NaN values are ignored.
%                     If all elements are NaN, the result is NaN.
%
%   See also PLUS, MINUS, MEAN, CUMSUM, DIFF.

%   Copyright 2014-2016 The MathWorks, Inc.

b = a;
b.millis = sum(a.millis,varargin{:});
if nargin > 1
    % Catch sum(a,'double') after built-in does error checking
    invalidFlags = strncmpi(varargin,'do',2);
    if any(invalidFlags)
        error(message('MATLAB:duration:InvalidNumericConversion',varargin{find(invalidFlags,1)}));
    end
end
