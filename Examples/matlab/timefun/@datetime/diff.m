function d = diff(a,varargin)
%DIFF Successive differences between datetimes as durations.
%   D = DIFF(T) returns an array of durations D containing time differences
%   between successive datetimes in T.
%
%   To compute differences between successive datetimes in T as calendar
%   durations, use CALDIFF.
%
%   When T is a vector, D is
%      [T(2)-T(1), T(3)-T(2), ..., T(END)-T(END-1)].
%
%   When DIFF(T) matrix, D(:,I) is
%      [T(2,I)-T(1,I), T(3,I)-T(2,I), ..., T(END,I)-T(END-1,I)].
%
%   When T is an N-D array, D contains differences along the first
%   non-singleton dimension of T.
%
%   D = DIFF(T,N) is the N-th order difference along the first non-singleton
%   dimension (denote it by DIM). If N >= SIZE(T,DIM), DIFF takes successive
%   differences along the next non-singleton dimension.
%
%   D = DIFF(X,N,DIM) is the N-th order difference along dimension DIM. If
%   N >= SIZE(T,DIM), DIFF returns an empty array.
%
%   Examples:
%
%      % Create a sequence of equally-spaced datetimes, and find their
%      % time differences.
%         t1 = datetime('now')
%         t = t1 + minutes(0:1.5:5)
%         dt = diff(t)
%
%      % Create a sequence of datetimes that crosses a US Daylight Saving
%      % Time change, and find their time differences.
%         t1 = datetime('02-Nov-2013 00:00:00','TimeZone','America/New_York')
%         t = t1 + caldays(0:3)
%         dt = diff(t)
%         dt2 = caldiff(t,'Days')
%
%   See also CALDIFF, BETWEEN, MINUS, PLUS, COLON, DURATION.

%   Copyright 2014-2017 The MathWorks, Inc.

d = duration.fromMillis(datetimeDiff(a.data,varargin{:}));
