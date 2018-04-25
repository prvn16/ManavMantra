function varargout = ymd(tt)
%YMD Year, month, and day numbers of tall array of datetimes.
%   [Y,M,D] = YMD(T)
%
%   See also DATETIME/YMD.

%   Copyright 2015-2016 The MathWorks, Inc.

nargoutchk(0,3);
[varargout{1:max(nargout,1)}] = datetimePiece(mfilename, 'double', tt);
end
