function tm = day(tt, varargin)
%DAY Day numbers or names of tall array of datetimes.
%   M = DAY(T)
%   M = DAY(T,KIND)

%   Copyright 2015-2016 The MathWorks, Inc.

narginchk(1,2);
% output is numeric or cellstr depending on KIND
tm = datetimePiece(mfilename, '', tt, varargin{:});
end
