function boolVal = isFPTLaunchedOnSameModel(fpt, modelObject)
%% helper function to determine FPT is open on the selected block in model.
% return true if FPT is already open on the selected block, mdlref,
% subsystem. Else returns false. 

%   Copyright 2016 The MathWorks, Inc.

model = fpt.getModel;
boolVal = isequal(get_param(model,'Object'), modelObject);
if ~boolVal
    % check for mdl ref
    try
        [refMdls,~] = find_mdlrefs(model);
        boolVal = any(strcmp(refMdls,modelObject.getFullName));
    catch mdl_not_found_exception %#ok<NASGU>
         % Don't relaunch FPT on error
         boolVal = true;
    end
end

end
