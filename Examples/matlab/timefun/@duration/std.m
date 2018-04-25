function b = std(a,varargin)
%STD Standard deviation of durations.
%   SD = STD(T), when T is a vector of durations, returns the sample standard
%   deviation of T as a scalar duration SD. When T is a matrix, STD(T) is a row
%   vector containing the standard deviation of each column.  For N-D arrays,
%   STD(T) is the standard deviation of the elements along the first
%   non-singleton dimension of T.
%
%   STD normalizes by (N-1), where N is the sample size.
%
%   SD = STD(T,1) normalizes by N. STD(T,0) is the same as STD(T).
%
%   SD = STD(T,FLAG,DIM) takes the standard deviation along the dimension DIM of
%   T.  Pass in FLAG==0 to use the default normalization by N-1, or 1 to use N.
%
%   SD = STD(..., MISSING) specifies how NaN (Not-A-Number) values are treated.
%
%      'includenan' - the standard deviation of a vector containing any NaN 
%                     values is also NaN. This is the default.
%      'omitnan'    - elements of T containing NaN values are ignored.
%                     If all elements are NaN, the result is NaN.
%
%   Example:
%
%      % Create an array of randomly distributed durations from a
%      % distribution with a std. dev. of 1 hour.  Find the std.
%      dur = minutes(randn(100,1))
%      std(dur)
%
%   See also MEAN, MEDIAN, MODE.

%   Copyright 2015 The MathWorks, Inc.

b = a;
b.millis = std(a.millis,varargin{:});
