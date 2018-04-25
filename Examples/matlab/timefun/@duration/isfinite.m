function tf = isfinite(a)
%ISFINITE True for durations that are finite.
%   TF = ISFINITE(A) for duration array A returns a logical array the same
%   size as A containing logical 1 (true) where the elements of A are Inf or
%   -Inf and logical 0 (false) where they are not.
%
%   For any array A of durations, exactly one of ISFINITE(A), ISINF(A), or
%   ISNAN(A) is true for each element.
%
%   Examples:
%
%      % Create an array of durations from numeric values containing Inf and NaN.
%      d = hours([1 2 Inf NaN 4])
%      isfinite(d)
%
%      % Create an array of durations, then assign in -Inf and NaN.
%      d = hours[1 2 3 4])
%      d(2) = -Inf
%      d(3) = NaN
%      isfinite(d)
%
%   See also ISINF, ISNAN.

%   Copyright 2014 The MathWorks, Inc.

tf = isfinite(a.millis);
