function isPathValid = validateBlockPath(this, blockPath)
    % VALIDATEBLOCKPATH verifies if the path provided is for the
    % block of selected type. Currently, it supports LUT and MFB blocks
    
    % Copyright 2017 The MathWorks, Inc. 
    
    % First check if the block path is valid 
    isPathValid = FunctionApproximation.internal.Utils.isBlockPathValid(blockPath);
    
    % If the path is valid, then check if the path is of specified type
    if isPathValid
        % Get the index of the selected type that can used to invoke the
        % validation function
        index =  this.validationFuncMap == this.SelectedType;
        isPathValid = FunctionApproximation.internal.Utils.(this.validationFuncMap(index, 2))(blockPath);
    end
end

