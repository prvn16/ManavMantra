function runName = getRunName(runObject)
%% GETRUNNAME function returns runName of a runObject of a given result
%
% result is an instance of fxptds.AbstractResult
% runName is cell Array representing name of fxptds.FPTRun associated with the
% result

%   Copyright 2016 The MathWorks, Inc.

    runName = {runObject.getRunName};
end