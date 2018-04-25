function tm = month(tt, varargin)
%MONTH Month numbers or names of tall array of datetimes.
%   M = MONTH(T)
%   M = MONTH(T,KIND)

%   Copyright 2015-2016 The MathWorks, Inc.

narginchk(1,2);
% output is numeric or cellstr depending on KIND
tm = datetimePiece(mfilename, '', tt, varargin{:});
end
