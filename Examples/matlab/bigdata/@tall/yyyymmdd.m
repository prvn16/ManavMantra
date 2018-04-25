function tm = yyyymmdd(tt)
%YYYYMMDD Convert tall array of datetimes to YYYYMMDD numeric values.
%   D = YYYYMMDD(T)
%
%   See also DATETIME/YYYYMMDD.

%   Copyright 2015-2016 The MathWorks, Inc.

tm = datetimePiece(mfilename, 'double', tt);
end
