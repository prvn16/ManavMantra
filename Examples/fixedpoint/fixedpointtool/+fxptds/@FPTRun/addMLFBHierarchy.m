function addMLFBHierarchy(this, blockHandle, functionIdentifiers)
%% ADDMLBHIERARCHY function updates MLFBHierarchyMap with blockHandle and 
% all the functionIdentifiers associated with it.

%   Copyright 2017 The MathWorks, Inc.
    
    if this.MLFBHierarchyMap.isKey(blockHandle)
        curFunctionIdentifiers = this.MLFBHierarchyMap(blockHandle);
        this.MLFBHierarchyMap(blockHandle) = [curFunctionIdentifiers; functionIdentifiers];
    else
        this.MLFBHierarchyMap(blockHandle) = functionIdentifiers;
    end    
end