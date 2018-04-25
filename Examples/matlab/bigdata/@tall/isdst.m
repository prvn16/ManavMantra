function tf = isdst(tt)
%ISDST True for tall array of datetimes occurring during Daylight Saving Time.
%   TF = ISDST(T)
%
%   See also DATETIME/ISDST.

%   Copyright 2015-2016 The MathWorks, Inc.

tf = datetimePiece(mfilename, 'logical', tt);
end
