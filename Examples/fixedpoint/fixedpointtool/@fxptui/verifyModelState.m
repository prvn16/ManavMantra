function [success, dlgType] = verifyModelState(model)
    % VERIFYMODELSTATE verifies the state of the model and reports
    % issues that would affect the Fixed-Point tool workflow

    % Copyright 2018 The MathWorks, Inc.
    
    % Set default values to outputs
    success = false;    
    dlgType = '';    
    
    % Currently, the only check performed is whether a model is locked for
    % some reason. We can add additional checks if and when deemed necessary. 
    lockStatus = get_param(model, 'Lock');
    if strcmp(lockStatus, 'on')        
        dlgType = 'errorModelLocked';
        return;
    end
    success = true;
end