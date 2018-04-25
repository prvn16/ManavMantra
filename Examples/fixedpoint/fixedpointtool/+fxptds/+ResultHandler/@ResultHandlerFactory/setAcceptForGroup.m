function setAcceptForGroup(this, result, value)
%% SETACCEPTFORGROUP function set Accept for a group of results
% 
% result is an instance of fxptds.AbstractResult whose accept value has
% been changed
%
% value is a boolean indicating the state of Accept check box for result in
% FPT GUI
%

%   Copyright 2016 The MathWorks, Inc.

    runObject = result.getRunObject;
    
    % get the group for the result triggering the action
    groupForResult = runObject.dataTypeGroupInterface.getGroupForResult(result);
    
    % set accept for the group
    this.ResultGroupHandler.setAcceptForGroups(runObject, groupForResult, value);    
end