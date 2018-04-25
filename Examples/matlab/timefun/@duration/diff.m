function b = diff(a,varargin)
%DIFF Duration differences.
%   DT = DIFF(T) returns a duration array DT containing differences between
%   successive durations in T.
%
%   When T is a vector, DT is
%      [T(2)-T(1), T(3)-T(2), ..., T(END)-T(END-1)].
%
%   When DIFF(T) matrix, DT(:,I) is
%      [T(2,I)-T(1,I), T(3,I)-T(2,I), ..., T(END,I)-T(END-1,I)].
%
%   When T is an N-D array, DT contains differences along the first
%   non-singleton dimension of T.
%
%   DT = DIFF(T,N) is the N-th order difference along the first non-singleton
%   dimension (denote it by DIM). If N >= SIZE(T,DIM), DIFF takes successive
%   differences along the next non-singleton dimension.
%
%   DT = DIFF(X,N,DIM) is the N-th order difference along dimension DIM. If
%   N >= SIZE(T,DIM), diff returns an empty array.
%
%   Example:
%
%      % Find successive differences in a vector of durations that is not sorted.
%      dur = hours([4 3 2 1 1 3 5 7])
%      diff(dur)

%   Copyright 2014-2017 The MathWorks, Inc.

b = a;
b.millis = diff(a.millis,varargin{:});
