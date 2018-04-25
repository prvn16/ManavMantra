function b = median(a,varargin)
%MEDIAN Median of durations.
%   M = MEDIAN(T), when T is a vector of durations. returns the sample median of
%   T as a scalar duration M. When T is a matrix, MEDIAN(T) is a row vector
%   containing the median value of each column.  For N-D arrays, MEDIAN(T) is the
%   median value of the elements along the first non-singleton dimension of T.
%   
%   M = MEDIAN(T,DIM) takes the median along the dimension DIM of T.
%
%   M = MEDIAN(..., MISSING) specifies how NaN (Not-A-Number) values are treated.
%
%      'includenan' - the median of a vector containing any NaN values is also NaN.
%                     This is the default.
%      'omitnan'    - elements of T containing NaN values are ignored.
%                     If all elements are NaN, the result is NaN.
%
%   Example:
%   
%      % Create an array of durations with random integers.  Find the
%      % median value.
%      dur = hours(randi(4,6,1))
%      median(dur)
%
%   See also MEAN, MODE, STD.

%   Copyright 2014-2015 The MathWorks, Inc.

b = a;
b.millis = median(a.millis,varargin{:});
