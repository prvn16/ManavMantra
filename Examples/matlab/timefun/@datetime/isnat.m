function tf = isnat(a)
%ISNAT True for datetimes that are Not-a-Time
%   TF = ISNAT(A) for datetime array A returns a logical array the same size as
%   A containing logical 1 (true) where the elements of A are Not-a-Time (NaT)
%   and logical 0 (false) where they are not. NaT represents a datetime that
%   is undefined.
%
%   Examples:
%
%      % Create an array of datetimes from numeric values containing NaN.
%      d = datetime(2014,[1 2 NaN 4],1)
%      isnat(d)
%
%      % Create an array of datetimes from strings, including the string 'NaT'.
%      d = datetime({'2014-1-1' '2014-2-1' 'NaT' '2014-4-1'})
%      isnat(d)
%
%      % Create an array of datetimes from strings, then assign a NaT.
%      d = datetime({'2014-1-1' '2014-2-1' '2014-3-1' '2014-4-1'})
%      d(3) = 'NaT'
%      isnat(d)
%
%      % Create an array of datetimes by adding durations containing NaN.
%      h = hours([1 2 NaN 4])
%      d = datetime('now') + h
%      isnat(d)
%
%   See also ISINF, ISFINITE, ISMISSING.

%   Copyright 2014-2016 The MathWorks, Inc.

tf = isnan(a.data);
