function success = loadReferencedModels(h)
% LOADREFERENCEDMODELS Load all model references in the tree node.

%   Copyright 2012-2013 The MathWorks, Inc.

success = true;

% Changes can happen to make the model node no longer valid: 
% - New model reference block added -> New model need to be loaded
% - Model reference block remains the same, but model was closed
% - Model block refer to another model -> old model needs to be removed
% - Model block changed to protected -> model has to be removed

mdlroot = h.getTopNode;
try
    [refMdls, ~] = find_mdlrefs(mdlroot.getDAObject.getFullName);
    if numel(refMdls) == 1 % only listed root model
        return; 
    end
catch mdl_not_found_exception % Model not on path.
    success = false;
    fxptui.showdialog('modelnotfound',mdl_not_found_exception);
    return;
end

childNodes = h.getFPTRoot.getModelNodes;
validNode = childNodes(1); % first one is always top model

for idx = 1:(length(refMdls)-1)
    refMdlName = refMdls{idx};
    load_system(refMdlName);
    mdlObj = get_param(refMdlName,'Object');
    % Check if the node already exists
    mdlNode = findobj(childNodes,'DAObject',mdlObj);
    if isempty(mdlNode)
        addNodeToTree(h, mdlObj); 
        % new node added here
        childNodes = h.getFPTRoot.getModelNodes;
        mdlNode = findobj(childNodes,'DAObject',mdlObj);
    end        % found the node
    validNode(end+1) = mdlNode; %#ok<AGROW>
end

% difference from childNodes
if length(validNode) < length(childNodes)
    setToRemove = setdiff(childNodes, validNode);
    for index = 1:length(setToRemove)
        modelName = setToRemove(index).DAObject.getFullName;
        removeModelNodes(h.getFPTRoot, modelName);        
        h.getFPTRoot.fireHierarchyChanged;
    end
end


