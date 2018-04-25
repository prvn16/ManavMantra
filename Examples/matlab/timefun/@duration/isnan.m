function tf = isnan(a)
%ISNAN True for durations that are Not-A-Number
%   TF = ISNAN(A) for duration array A returns a logical array the same size as
%   A containing logical 1 (true) where the elements of A are NaN and logical 0
%   (false) where they are not. NaN represents a duration that is undefined.
%
%   Examples:
%
%      % Create an array of durations from numeric values containing NaN.
%      d = hours([1 2 NaN 4])
%      isnan(d)
%
%      % Create an array of durations, then assign a NaN.
%      d = hours[1 2 3 4])
%      d(3) = NaN
%      isnan(d)
%
%   See also ISINF, ISFINITE.

%   Copyright 2014 The MathWorks, Inc.

tf = isnan(a.millis);
