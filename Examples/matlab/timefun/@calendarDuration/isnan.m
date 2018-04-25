function tf = isnan(a)
%ISNAN True for calendar durations that are Not-a-Number.
%   TF = ISNAN(A) for calendar duration array A returns a logical array the same
%   size as A containing logical 1 (true) where the elements of A are NaN and
%   logical 0 (false) where they are not. NaN represents an element of a
%   calendar duration array that is undefined.
%
%   Examples:
%
%      % Create an array of calendar durations from numeric values containing NaN.
%      d = caldays([1 2 NaN 4])
%      isnan(d)
%
%   See also ISINF, ISFINITE.

%   Copyright 2014 The MathWorks, Inc.

components = a.components;
% A scalar zero placeholder is a no-op for this test.
tf = isnan(components.months) | isnan(components.days) | isnan(components.millis);
