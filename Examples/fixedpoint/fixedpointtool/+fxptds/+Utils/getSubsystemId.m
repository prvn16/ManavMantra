function subsystemId = getSubsystemId(result)
%% GETSUBYSTEMID function returns the unique id of the parent subsystem of a result
%
% result is an instance of fxptds.AbstractResult
% subsystemId is a cell array representing the unique key of the parent
% subsystem

%   Copyright 2016 The MathWorks, Inc.

    subsystemId = result.getSubsystemId;
end