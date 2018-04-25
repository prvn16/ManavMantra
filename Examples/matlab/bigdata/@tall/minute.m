function tm = minute(tt)
%MINUTE Minute numbers of tall array of datetimes.
%   M = MINUTE(T)
%
%   See also DATETIME/MINUTE.

%   Copyright 2015-2016 The MathWorks, Inc.

tm = datetimePiece(mfilename, 'double', tt);
end
