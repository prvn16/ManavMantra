function [canUse, result] = canUseParallelPool()
%CANUSEPARALLELPOOL Check if parallel functionality can be used
%   ok = CANUSEPARALLELPOOL returns true if PCT is installed and licensed,
%   and there is a pool running. The function will attempt to start a pool
%   if one is not already running and will return true if the pool was 
%   started.
%
%   [ok, details] = CANUSEPARALLELPOOL will populate the 'details'
%   structure with the following information:
%
%   IsInstalled:  (logical) true if PCT is installed, otherwise false
%   IsLicensed:   (logical) true if PCT is licensed, otherwise false
%   PoolRunning:  (logical) true if there is a parallel pool running or
%                           a new one has been started; otherwise false
%   ErrorMessage: (char)    a message indicating the error that occurred
%                           while attempting to get or create the parallel
%                           pool. This will be an empty string if no
%                           errors were encountered.
%
%   See also matlab.internal.parallel.isPCTInstalled,
%            matlab.internal.parallel.isPCTLicensed,
%            gcp, parpool, parfor, parfeval.

%   Copyright 2015 The MathWorks, Inc.

result = struct(...
    'IsInstalled', matlab.internal.parallel.isPCTInstalled(), ...
    'IsLicensed', false, ...
    'PoolRunning', false, ...
    'ErrorMessage', '');
if result.IsInstalled
    result.IsLicensed = matlab.internal.parallel.isPCTLicensed();
    if result.IsLicensed
        try
            pool = gcp();
            result.PoolRunning = ~isempty(pool) && pool.Connected;
        catch E
            result.ErrorMessage = E.message;
        end
    end
end
canUse = result.IsInstalled && result.IsLicensed && result.PoolRunning;
end
