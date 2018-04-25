function tm = isnat(tt)
%ISNAT True for datetimes that are Not-a-Time.
%   TF = ISNAT(A)
%
%   See also DATETIME/ISNAT.

%   Copyright 2016 The MathWorks, Inc.

tm = datetimePiece(mfilename, 'logical', tt);
end
