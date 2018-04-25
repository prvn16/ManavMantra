function updateMappingOfAllAncestors(this, modelMap, parentKey, resultIDs, subsysRows)
% UPDATEMAPPINGOFALLANCESTORS The order in which the keys get processed do
% not gaurantee that all children are processed before its parent. Hence,
% for any given parent, recursively add the new results to all its
% ancestors up the chain to gaurantee correct result maps. Fix for g1465800
% & 1467760 

% Copyright 2016-2017 The MathWorks, Inc.

if modelMap.isKey(parentKey)
    parentKey = modelMap(parentKey);
    
    % (NR) Don't add FPTRoot to the map since no results are supposed
    % to show up in spreadsheet    
    while ~isempty(parentKey) && ~strcmp(parentKey, 'FPTRoot')
        this.addResultIdsToMap(parentKey, resultIDs, subsysRows);
        if modelMap.isKey(parentKey)
            parentKey = modelMap(parentKey);
        else
            parentKey = '';
        end
    end
end
end