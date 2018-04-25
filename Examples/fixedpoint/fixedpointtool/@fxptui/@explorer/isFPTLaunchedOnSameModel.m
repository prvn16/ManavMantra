function boolVal = isFPTLaunchedOnSameModel(me, modelObject)
%% helper function to determine FPT is open on the selected block in model.
% return true if FPT is already open on the selected block, mdlref,
% subsystem. Else returns false. 

%   Copyright 2015 The MathWorks, Inc.

boolVal = isequal(me.getTopNode.DAObject, modelObject);
if ~boolVal
    % check for mdl ref
    [refMdls,~] = find_mdlrefs(me.getTopNode.DAObject.getFullName);
    boolVal = any(strcmp(refMdls,modelObject.getFullName));
end

end