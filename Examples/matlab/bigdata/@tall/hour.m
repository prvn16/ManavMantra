function th = hour(tt)
%HOUR Hour numbers of tall array of datetimes.
%   H = HOUR(T)
%
%   See also DATETIME/HOUR.

%   Copyright 2015-2016 The MathWorks, Inc.

th = datetimePiece(mfilename, 'double', tt);
end
