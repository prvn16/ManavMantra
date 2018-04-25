function td = timeofday(tt)
%TIMEOFDAY Elapsed time since midnight for tall array of datetimes.
%   D = TIMEOFDAY(T)
%
%   See also DATETIME/TIMEOFDAY.

%   Copyright 2015-2016 The MathWorks, Inc.

td = datetimePiece(mfilename, 'duration', tt);
end
