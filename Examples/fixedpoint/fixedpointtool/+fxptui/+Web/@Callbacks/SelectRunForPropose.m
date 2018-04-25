function SelectRunForPropose(clientSelectedRun, proposalEditFieldChanges)
% SELECTRUNFORPROPOSE

%   Copyright 2015-2018 The MathWorks, Inc.

if nargin < 1
    clientSelectedRun = '';
end
b = fxptui.checkInstall;
if ~b
    fxptui.showdialog('nofixptlicensepropose');
    return;
end

fpt = fxptui.FixedPointTool.getExistingInstance;
if ~isempty(fpt)    
    % g1696210 - FPT should throw an error when the model is 
    % locked and should not hang
    [success, dlgType] = fxptui.verifyModelState(fpt.getModel);
    if ~success
        fxptui.showdialog(dlgType);
        return;
    end
    % re-populate the referenced models if they were previously closed
    success = fpt.loadReferencedModels;
    if ~success
        return; 
    end
    
    if isempty(clientSelectedRun)
        clientSelectedRun = get_param(fpt.getModel,'FPTRunName');
    end
    appData = SimulinkFixedPoint.getApplicationData(fpt.getModel);
    if (nargin > 1)
        for i = 1:numel(proposalEditFieldChanges)
            fpt.getWorkflowController.updateProposalOptions(proposalEditFieldChanges{i});
        end
    end
    appData.ScaleUsing = clientSelectedRun;
    fxptui.Web.Callbacks.Propose;
end
end

% LocalWords:  nofixptlicensepropose FPT
