function b = mean(a,varargin)
%MEAN Mean of durations.
%   M = MEAN(T), when T is a vector of durations, returns the sample mean of T
%   as a scalar duration M. When T is a matrix, MEAN(T) is a row vector
%   containing the mean value of each column.  For N-D arrays, MEAN(T) is the
%   mean value of the elements along the first non-singleton dimension of T.
%   
%   M = MEAN(T,DIM) takes the mean along the dimension DIM of T.
%
%   M = MEAN(..., MISSING) specifies how NaN (Not-A-Number) values are treated.
%
%      'includenan' - the mean of a vector containing any NaN values is also NaN.
%                     This is the default.
%      'omitnan'    - elements of T containing NaN values are ignored.
%                     If all elements are NaN, the result is NaN.
%
%   Example:
%   
%      % Create an array of randomly distributed durations from a
%      % distribution with a mean of 5 hrs and std. dev. of 1 minute.  Find the
%      % mean. 
%      dur = minutes(randn(100,1))+hours(5)
%      mean(dur)
%
%   See also STD, MEDIAN, MODE.

%   Copyright 2014-2015 The MathWorks, Inc.

b = a;
b.millis = mean(a.millis,varargin{:});
if nargin > 1
    % Catch mean(a,'double') after built-in does error checking
    invalidFlags = strncmpi(varargin,'do',2);
    if any(invalidFlags)
        error(message('MATLAB:duration:InvalidNumericConversion',varargin{find(invalidFlags,1)}));
    end
end
