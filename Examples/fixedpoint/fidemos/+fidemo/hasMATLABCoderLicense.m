function flag = hasMATLABCoderLicense()
%hasMATLABCoderLicense   MATLAB Coder license availability
%   hasMATLABCoderLicense returns true (1) if a MATLAB Coder license is available.
%    If no MATLAB Coder license is available, it returns false (0).

%    Copyright 2010 The MathWorks, Inc.

flag = license('test', 'MATLAB_Coder');

