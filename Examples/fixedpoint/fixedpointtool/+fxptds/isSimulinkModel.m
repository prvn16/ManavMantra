function isModel = isSimulinkModel(sid)
% ISSIMULINKMODEL Return true if the SID resolves to a loaded Simulink model.

%    Copyright 2012 MathWorks, Inc.


isModel = false;
try
    modelName = Simulink.ID.getModel(sid);
    mdlObj = get_param(modelName,'Object');
    if isa(mdlObj,'Simulink.Object')
        isModel = true;
    end
catch e  %#ok<NASGU>
    % ignore error. Model doesn't exist or is not loaded.
end


