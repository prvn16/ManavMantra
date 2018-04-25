function tf = isfinite(a)
%ISFINITE True for calendar durations that are finite.
%   TF = ISINF(A) for calendar duration array A returns a logical array the same
%   size as A containing logical 1 (true) where the elements of A are Inf or
%   -Inf and logical 0 (false) where they are not.
%
%   For any array A of calendar durations, exactly one of ISFINTE(A), ISINF(A),
%   or ISNAN(A) is true for each element.
%
%   Examples:
%
%      % Create an array of calendar durations from numeric values containing Inf and NaN.
%      d = caldays([1 Inf 3 NaN 5 -Inf])
%      isfinite(d)
%
%   See also ISINF, ISNAN.

%   Copyright 2014 The MathWorks, Inc.

components = a.components;
% A scalar zero placeholder is a no-op for this test.
tf = isfinite(components.months) & isfinite(components.days) & isfinite(components.millis);
