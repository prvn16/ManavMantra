function setProposedDTForGroup(this, result, value)
%% SETPROPOSEDDTFORGROUP function sets ProposedDT for a group of results
% 
% result is an instance of fxptds.AbstractResult whose proposedDT value has
% been changed
%
% value is an instance of SimulinkFixedPoint.DTContainerInfo indicating the
% container info of the result


%   Copyright 2016 The MathWorks, Inc.

    %% If run name is from single - dont update groups
    % there is no need for an update when the results is under double to
    % single conversion
    if ~strcmpi(result.getRunName, 'D2S_Run_Collector_Internal_Run_Name')
        
        % Otherwise update results in the group with proposed dt (value)
        this.ResultGroupHandler.setProposedDTForGroup(result, value);
    end
end