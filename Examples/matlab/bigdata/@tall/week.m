function tm = week(tt, varargin)
%WEEK Week numbers of tall array of datetimes.
%   M = WEEK(T)
%   M = WEEK(T,KIND)

%   Copyright 2015-2016 The MathWorks, Inc.

narginchk(1,2);
% Output is always double regardless of KIND.
tm = datetimePiece(mfilename, 'double', tt, varargin{:});
end
