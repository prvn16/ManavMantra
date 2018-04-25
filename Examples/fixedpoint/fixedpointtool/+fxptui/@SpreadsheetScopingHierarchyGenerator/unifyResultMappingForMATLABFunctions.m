function unifyResultMappingForMATLABFunctions(this)
% UNIFYRESULTMAPPINGFORMATLABFUNCTIONS Create a map between a function name
% and its identifiers. For a MATLAB function block node, the same function
% can have different identifiers due to specializations. A map is used to
% create unique entries. The values are later used to consolidate results.
% The user should see all the results belonging to a function though its
% identifiers are different.

% Copyright 2016-2017 The MathWorks, Inc.

fpt = fxptui.FixedPointTool.getExistingInstance;
addedTreeData = fpt.getModelHierarchy.getAddedTreeData;
nameIDMap = containers.Map('KeyType','char','ValueType','any');
for k = 1: numel(addedTreeData)
    treeData = addedTreeData(k);
    oldVal = [];
    if nameIDMap.isKey(treeData.name)
        oldVal =  nameIDMap(treeData.name);
    end
    if isempty(regexp(treeData.identifier, '_dummy$', 'once'))
        if ~isempty(oldVal) && isequal(oldVal(1).parent, treeData.parent)
            nameIDMap(treeData.name) = [oldVal, treeData];
        else
            nameIDMap(treeData.name) = treeData;
        end
    end
end

% Unify all the results belonging to a function though
% its identifiers are different
idValues = nameIDMap.values;
for m = 1:numel(idValues)
    treeArray = idValues{m};
    ids = {};
    for p = 1:numel(treeArray)
        ids{p} = treeArray(p).identifier; %#ok<AGROW>
    end
    combinedSet = unique(this.getResultSetForIDs(unique(ids)));
    for n = 1:numel(ids)
        this.ResultScopingMap(ids{n}) = combinedSet;
    end
end
end