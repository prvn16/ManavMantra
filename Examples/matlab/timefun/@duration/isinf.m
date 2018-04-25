function tf = isinf(a)
%ISINF True for durations that are +Inf or -Inf.
%   TF = ISINF(A) for duration array A returns a logical array the same size as
%   A containing logical 1 (true) where the elements of A are Inf or -Inf and
%   logical 0 (false) where they are not.
%
%   Examples:
%
%      % Create an array of durations from numeric values containing Inf.
%      d = hours([1 2 Inf 4])
%      isinf(d)
%
%      % Create an array of durations, then assign a -Inf.
%      d = hours[1 2 3 4])
%      d(3) = -Inf
%      isinf(d)
%
%   See also ISNAN, ISFINITE.

%   Copyright 2014 The MathWorks, Inc.

tf = isinf(a.millis);
