function updateUI(~,result)
%% UPDATEUI function updates GUI with the latest result's value
% ME GUI handler requires fireProportyChange
%
%  result is an instance of fxptds.AbstractResult

%   Copyright 2016 The MathWorks, Inc.
    
    % This GUIHandler handles changes for Model Explorer based FPT 
    % When a result group is updated, each result in the group should be
    % refreshed independently to reflect changes in UI. 
    % g1488298
    % Note: This change is not required for FPT Web 
    if (result.hasDTGroup)
        
        % Get result's group name
        runObject = result.getRunObject;
        dtGroup = result.getDTGroup;
        
        % Query for group members from the group. The group ids did not
        % have "G" label in DataTypeGroupInterface of the run object.
        dtGroup = strrep(dtGroup, 'G', '');
        groupMembers = runObject.dataTypeGroupInterface.dataTypeGroups(dtGroup).members.values;
        for idx = 1:numel(groupMembers)
            
            % For each group member, fire property change.
            groupMembers{idx}.firePropertyChange;
        end
    else
        % for results without group, fire property change
        result.firePropertyChange;
    end
end