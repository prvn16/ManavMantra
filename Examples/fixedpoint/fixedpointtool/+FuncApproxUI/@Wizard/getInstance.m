function obj = getInstance
    % GETINSTANCE Returns the stored instance of the repository.
    
    % Copyright 2017 The MathWorks, Inc.
    
    persistent localObj
    if isempty(localObj) || ~isvalid(localObj)
        localObj = FuncApproxUI.Wizard;
    end
    obj = localObj;
end
