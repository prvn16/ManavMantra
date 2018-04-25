function setAccept(this, result, value)
%% SETACCEPT function handles setting "Accept" field for MLFB Results
% Functional behavior: Access all results within MLFB, update accept status
% of all the results with value
% If any of the MLFB results belong to a group, update accept status of
% results of the group as well.
% 
% result is an instance of fxptds.AbstractResult whose accept value has
% been changed
%
% value is a boolean indicating the state of Accept check box for result in
% FPT GUI
%

%   Copyright 2016 The MathWorks, Inc.

	% get run object from result
    runObject = result.getRunObject;

    % get the group for the result
    group = runObject.dataTypeGroupInterface.getGroupForResult(result);
    
    % For each group, set Accept for all results in the group
    this.ResultGroupHandler.setAcceptForGroups(runObject, group, value);
    
end