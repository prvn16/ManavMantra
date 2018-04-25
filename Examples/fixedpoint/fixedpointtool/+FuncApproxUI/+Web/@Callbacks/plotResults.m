function plotResults
    % PLOTRESULTS Callback to show/ compare Lut results.
    
    % Copyright 2017 The MathWorks, Inc.
    
    lutInstance = FuncApproxUI.Wizard.getExistingInstance;
    lutCtrl = lutInstance.getWizardController;
    solution = lutCtrl.getLutSolution;
    if ~isempty(solution)
        try
            solution.compare;
        catch e
            FuncApproxUI.Utils.showDialog('invalidPlot', e);
        end
    end
end

