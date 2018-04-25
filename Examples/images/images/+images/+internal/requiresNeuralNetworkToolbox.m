function requiresNeuralNetworkToolbox(myFunction)
% Verify that the Neural Network Toolbox is available.

% Copyright 2017 The MathWorks, Inc.

% check if nnet is installed first.
if isdeployed
    isInstalled = isdir(fullfile(ctfroot, 'toolbox', 'nnet'));
else    
    isInstalled = isdir(fullfile(matlabroot, 'toolbox', 'nnet'));
end

if ~isInstalled
    exception = MException(message('images:validate:nnetNotInstalled',myFunction));
    throwAsCaller(exception);
end

% check out a license. Request 2nd output to prevent message printing.
[isLicensePresent, ~] = license('checkout','neural_network_toolbox');

if ~isLicensePresent
    exception = MException(message('images:validate:nnetLicenseUnavailable',myFunction));
    throwAsCaller(exception);    
end