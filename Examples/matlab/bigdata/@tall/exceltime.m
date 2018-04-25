function te = exceltime(tt, varargin)
%EXCELTIME Convert tall array of datetimes to Excel serial date numbers.
%   E = EXCELTIME(T)
%   E = EXCELTIME(T,KIND)
%
%   See also DATETIME/EXCELTIME.

%   Copyright 2015-2016 The MathWorks, Inc.

narginchk(1,2);
% output is numeric or cellstr depending on KIND
te = datetimePiece(mfilename, '', tt, varargin{:});
end
