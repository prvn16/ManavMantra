function blockPath = getCurrentBlock
    % getCurrentBlock Callback to get the selected lookup table block path.
    
    % Copyright 2017 The MathWorks, Inc.
    
    lutInstance = FuncApproxUI.Wizard.getExistingInstance;
    % Check for open model and selected block type
    isAnyModelOpen = FunctionApproximation.internal.Utils.isAnyModelOpen;
    if ~isAnyModelOpen
        FuncApproxUI.Utils.showDialog('noOpenModel');
        return;
    end
    lutDataManager = lutInstance.getWizardController.getDataManager();
    blockPath = lutDataManager.getCurrentBlockPath;
    lutInstance.getWizardController.publishCurrentBlockPath(blockPath);
end

