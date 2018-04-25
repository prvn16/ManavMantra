function Tb = emlGetBestPrecForMxArray(Bmx,Ta)
%emlGetBestPrecForMxArray  Get best-precision numerictype for builtin array input
%   emlGetBestPrecForMxArray(B,T) returns a numerictype object with
%   best-precision fraction length, keeping all other parameters of numerictype
%   object T the same.
%
%   Example:
%     T  = numerictype;
%     B  = magic(4);
%     Tb = emlGetBestPrecForMxArray(B,T)

%   This is used as a private function for Embedded MATLAB.
%
%   Copyright 1999-2015 The MathWorks, Inc.
narginchk(2,2);
Tb = embedded.fi.GetBestPrecisionForMxArray(Bmx,Ta);