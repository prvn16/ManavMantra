function tm = second(tt, varargin)
%SECOND Second numbers of tall array of datetimes.
%   M = SECOND(T)
%   M = SECOND(T,KIND)
%
%   See also DATETIME/SECOND.

%   Copyright 2015-2016 The MathWorks, Inc.
narginchk(1,2);
% Output always double regardless of KIND
tm = datetimePiece(mfilename, 'double', tt, varargin{:});
end
