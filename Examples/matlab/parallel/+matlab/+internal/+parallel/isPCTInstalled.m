function tf = isPCTInstalled()
%ISPCTINSTALLED Check if the Parallel Computing Toolbox is installed
%   See also matlab.internal.parallel.isPCTLicensed,
%            matlab.internal.parallel.canUseParallelPool.

%   Copyright 2015 The MathWorks, Inc.
persistent RESULT;
if isempty(RESULT)
    RESULT = ~isequal(exist('parallel.Pool', 'class'), 0);
end
tf = RESULT;
end
