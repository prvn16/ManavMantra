function setAcceptForGroups(this, runObj, group, value)
    % SETACCEPTFORGROUPS runs setAcceptForGroup on each group in groupLabels
    %
    % group is the data type group that corresponds to the result that
    % triggered the action
    %
    % runObj is an instance of fxptds.FPTRun
    %
    % value is boolean reppresenting the accept check box state
    %
    % Copyright 2016-2017 The MathWorks, Inc.
    
    % initialize all groups cell array with the group that triggered the
    % action
    allGroups = {group};
    count = 1;
    while count <= length(allGroups)
        % gather all the groups that might be associated with the group
        % NOTE: the function will return a cell array that will have all
        % the groups that come from MLFB blocks; if any. In any case we
        % need to recursively make sure that we collected all the groups
        % that are formed due to MLFB.
        
        members = allGroups{count}.getGroupMembers();
        countMLVar = 0; 
        for idxMember = 1:numel(members)
            if isa(members{idxMember}, 'fxptds.MATLABVariableResult')
                countMLVar = countMLVar + 1; 
            end
        end
                
        if (countMLVar > 1) || (count == 1)
            
            mlfbGroups = this.collectGroupsForBatchAccept(runObj, allGroups{count});
                        
            mlfbGroupIDs = zeros(1, numel(mlfbGroups)); 
            for idxMLFBGrp = 1:numel(mlfbGroups)
                mlfbGroupIDs(idxMLFBGrp) = mlfbGroups{idxMLFBGrp}.id; 
            end
            
            % get the IDs of the groups that are already in the queue
            % existingIDs = cellfun(@(x)(x.id), allGroups);
            existingIDs = zeros(1, numel(allGroups)); 
            for idxGrp = 1:numel(allGroups)
                existingIDs(idxGrp) = allGroups{idxGrp}.id; 
            end
            
            
            % perform a set diff to get only the groups that are not in the
            % queue already
            [~, newIDsIndex] = setdiff(mlfbGroupIDs, existingIDs);
            
            % add any new groups in the queue
            allGroups = [allGroups mlfbGroups(newIDsIndex)]; %#ok<AGROW>
        end
       
        % increment to collect from the next group in the queue
        % NOTE: if in the current collection we did not see any new groups,
        % eventually the counter will run over the length of all collected
        % groups and the loop will break
        count = count + 1;
    end
    
    % Calling setAcceptForGroup for each group 
    for idxAllGrp = 1:numel(allGroups)
        this.setAcceptForGroup(allGroups{idxAllGrp}, value); 
    end
    
end
