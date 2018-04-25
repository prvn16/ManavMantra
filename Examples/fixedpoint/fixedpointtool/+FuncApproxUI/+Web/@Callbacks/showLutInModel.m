function showLutInModel
    % SHOWLUTINMODEL Callback to show the optimized Lut block
    % in a new model
    
    % Copyright 2017 The MathWorks, Inc.
    
    lutInstance = FuncApproxUI.Wizard.getExistingInstance;
    lutCtrl = lutInstance.getWizardController;
    solution = lutCtrl.getLutSolution;
    if ~isempty(solution)
        solution.approximate;
    end
end
