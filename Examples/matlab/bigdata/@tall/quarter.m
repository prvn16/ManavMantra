function tq = quarter(tt)
%QUARTER Quarter numbers of tall array of datetimes.
%   Q = QUARTER(T)
%
%   See also DATETIME/QUARTER.

%   Copyright 2015-2016 The MathWorks, Inc.

tq = datetimePiece(mfilename, 'double', tt);
end
