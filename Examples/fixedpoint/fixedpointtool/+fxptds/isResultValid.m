function isValid = isResultValid(result)
    % ISRESULT Resturns true if the input is an valid object of type
    % fxptui.abstractresult
    
    %  Copyright 2012-2016 The MathWorks, Inc.
    
    % return true only if:
    % 1) Result should be an object of type fxptds.AbstractResult
    % 2) Result is a valid handle
    % 3) Result points to valid entity (block, ID etc)
    
    isValid = isa(result,'fxptds.AbstractResult') && ...
        result.isvalid && ...
        result.isResultValid;
end
