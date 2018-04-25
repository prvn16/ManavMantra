function tf = isinf(a)
%ISINF True for calendar durations that are +Inf or -Inf.
%   TF = ISINF(A) for calendar duration array A returns a logical array the same
%   size as A containing logical 1 (true) where the elements of A are Inf or
%   -Inf and logical 0 (false) where they are not.
%
%   Examples:
%
%      % Create an array of calendar durations from numeric values containing Inf.
%      d = caldays([1 2 Inf 4])
%      isinf(d)
%
%   See also ISNAN, ISFINITE.

%   Copyright 2014 The MathWorks, Inc.

components = a.components;
% A scalar zero placeholder is a no-op for this test.
tf = isinf(components.months) | isinf(components.days) | isinf(components.millis);
