function launchFPTOnModelRename(modelObj, oldMdlName)
%LAUNCHFPTONMODELRENAME Re-launch the FPT with the updated model name
% This callback is executed when a model 'save as' operation
% is performed. The callback updates the model name and launch the FPT

%   Copyright 2016 The MathWorks, Inc.

newMdlName = modelObj.getFullName;
fpt = fxptui.FixedPointTool.getExistingInstance;

if ~isempty(fpt)
    % Update only if the model name is different.
    if ~strcmpi(newMdlName, oldMdlName)
        fpt.deleteBlockDiagramCallbacks;
        selectedSystem = fpt.getSystemForConversion;
        
        fpt.close;
        
        % re-launch the fpt with the updated System for Conversion
        fxptui.FixedPointTool.launch(selectedSystem);
    end
end

end

