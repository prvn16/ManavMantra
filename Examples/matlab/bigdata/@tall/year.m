function ty = year(tt, varargin)
%YEAR Year numbers of tall array of datetimes.
%   Y = YEAR(T)
%   Y = YEAR(T,KIND)
%
%   See also: DATETIME/YEAR, TALL.

%   Copyright 2015-2016 The MathWorks, Inc.

narginchk(1,2);
% output is numeric regardless of KIND
ty = datetimePiece(mfilename, 'double', tt, varargin{:});
end
