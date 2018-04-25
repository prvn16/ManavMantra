function setAcceptForGroup(this, group, value)
    %% SETACCEPTFORGROUP function sets accepts property for all results in a group
    %
    % runObj is an instance of fxptds.FPTRun
    %
    % group is an object fxptds.DataTypeGroup
    %
    % value is boolean reppresenting the accept check box state
    %
    %   Copyright 2016 The MathWorks, Inc.
    
    sharedGroupResults = group.getGroupMembers();
    cellfun(@(x) this.updateAcceptFlag(x, value), sharedGroupResults);
    
end
