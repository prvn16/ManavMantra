function Simulate(action)
% SIMULATE Simulate the model

% Copyright 2015-2018 The MathWorks, Inc.

fpt = fxptui.FixedPointTool.getExistingInstance;
if isempty(fpt)
    return
end
mdl = fpt.getModel;
% g1696210 - FPT should throw an error when the model is
% locked and should not hang
[success, dlgType] = fxptui.verifyModelState(mdl);
if ~success
    fxptui.showdialog(dlgType);
    return;
end
mdlObj = get_param(mdl,'Object');
if(~isa(mdlObj, 'Simulink.BlockDiagram'))
    return;
end

simHandler = fxptui.Web.SimulationHandler(mdl);
simHandler.Simulate(action);

end


%---------------------------------------------------------------------------
% [EOF]

% LocalWords:  fpt simmodewarning ignoreproposalsandsimwarning btn Ignoreand
