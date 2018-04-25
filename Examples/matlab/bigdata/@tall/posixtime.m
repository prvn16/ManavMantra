function tp = posixtime(tt)
%POSIXTIME Converts tall array of datetimes to Posix times.
%   P = POSIXTIME(T)
%
%   See also DATETIME/POSIXTIME.

%   Copyright 2015-2016 The MathWorks, Inc.

tp = datetimePiece(mfilename, 'double', tt);
end
