function propagateAlertLevel(this, finalAlertLevels)
    % PROPAGATEALERTLEVEL this function is responsible to propagate the
    % final alert level of the group to the group members
    
    % Copyright 2016 The MathWorks, Inc.
    
    groupMembers = this.getGroupMembers();
    
    
    % propagate the final alert level to all group members
    for memberIndex = 1:numel(groupMembers)
        
        % get the string representation of the final alert level
        finalAlertLevelStr = lower(char(finalAlertLevels(memberIndex)));
        
        % set the alert level to the final alert level
        groupMembers{memberIndex}.setAlert(finalAlertLevelStr);
    end
end