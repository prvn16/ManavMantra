function varargout = tzoffset(tt)
%TZOFFSET Time zone offset of tall array of datetimes.
%   DT = TZOFFSET(T)
%   [DT,DST] = TZOFFSET(T)
%
%   See also DATETIME/TZOFFSET.

%   Copyright 2015-2016 The MathWorks, Inc.

nargoutchk(0,2);
[varargout{1:max(nargout,1)}] = datetimePiece(mfilename, 'duration', tt);
end
