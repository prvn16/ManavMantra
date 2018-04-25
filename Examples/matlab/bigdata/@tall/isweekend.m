function tf = isweekend(tt)
%ISWEEKEND True for tall array of datetimes occurring on a weekend.
%   TF = ISWEEKEND(T)
%
%   See also DATETIME/ISWEEKEND.

%   Copyright 2015-2016 The MathWorks, Inc.

tf = datetimePiece(mfilename, 'logical', tt);
end
