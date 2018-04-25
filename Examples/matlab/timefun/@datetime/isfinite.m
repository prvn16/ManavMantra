function tf = isfinite(a)
%ISFINITE True for datetimes that are finite.
%   TF = ISFINITE(A) for datetime array A returns a logical array the same
%   size as A containing logical 1 (true) where the elements of A are finite
%   and logical 0 (false) where they are not.
%
%   For any array A of datetimes, exactly one of ISFINITE(A), ISINF(A), or
%   ISNAT(A) is true for each element.
%
%   Examples:
%
%      % Create an array of datetimes from numeric values containing Inf and NaN.
%      d = datetime(2014,[1 Inf NaN 4],1)
%      isfinite(d)
%
%      % Create an array of datetimes from strings, including 'Inf' and 'NaT'.
%      d = datetime({'2014-1-1' 'Inf' 'NaT' '2014-4-1'})
%      isfinite(d)
%
%      % Create an array of datetimes from strings, then assign -Inf and NaT.
%      d = datetime({'2014-1-1' '2014-2-1' '2014-3-1' '2014-4-1'})
%      d(2) = '-Inf'
%      d(3) = 'NaT'
%      isfinite(d)
%
%      % Create an array of datetimes by adding durations containing -Inf and NaN.
%      h = hours([1 -Inf NaN 4])
%      d = datetime('now') + h
%      isfinite(d)
%
%   See also ISINF, ISNAT.

%   Copyright 2014 The MathWorks, Inc.

tf = isfinite(a.data);
