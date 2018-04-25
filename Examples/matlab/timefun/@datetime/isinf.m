function tf = isinf(a)
%ISINF True for datetimes that are +Inf or -Inf.
%   TF = ISINF(A) for datetime array A returns a logical array the same size
%   as A containing logical 1 (true) where the elements of A are Inf or -Inf
%   and logical 0 (false) where they are not.
%
%   Examples:
%
%      % Create an array of datetimes from numeric values containing Inf.
%      d = datetime(2014,[1 2 Inf 4],1)
%      isinf(d)
%
%      % Create an array of datetimes from strings, including the string 'Inf'.
%      d = datetime({'2014-1-1' '2014-2-1' 'Inf' '2014-4-1'})
%      isinf(d)
%
%      % Create an array of datetimes from strings, then assign a -Inf.
%      d = datetime({'2014-1-1' '2014-2-1' '2014-3-1' '2014-4-1'})
%      d(3) = '-Inf'
%      isinf(d)
%
%      % Create an array of datetimes by adding durations containing -Inf.
%      h = hours([1 2 -Inf 4])
%      d = datetime('now') + h
%      isinf(d)
%
%   See also ISNAT, ISFINITE.

%   Copyright 2014 The MathWorks, Inc.

tf = isinf(a.data);
