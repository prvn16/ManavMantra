function tf = isPCTLicensed()
%ISPCTLICENSED Check if there is a license for using PCT
%   See also matlab.internal.parallel.isPCTInstalled,
%            matlab.internal.parallel.canUseParallelPool.

%   Copyright 2015-2017 The MathWorks, Inc.
tf = license('test', 'Distrib_Computing_Toolbox') == 1;
end
