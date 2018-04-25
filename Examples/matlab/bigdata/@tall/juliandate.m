function tjd = juliandate(tt, varargin)
%JULIANDATE Convert tall array of datetimes to Julian dates
%   JD = JULIANDATE(T)
%   MJD = JULIANDATE(T,KIND)
%
%   See also DATETIME/JULIANDATE.

%   Copyright 2015-2016 The MathWorks, Inc.

narginchk(1,2);
% output is numeric or cellstr depending on KIND
tjd = datetimePiece(mfilename, '', tt, varargin{:});
end
