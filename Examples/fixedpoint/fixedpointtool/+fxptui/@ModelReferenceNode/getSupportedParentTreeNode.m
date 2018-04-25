function treenode = getSupportedParentTreeNode(this)
% GETSUPPORTEDPARENTTREENODE Get the closes supported parent node for an
% action.

% Copyright 2013 The MathWorks, Inc.

    me = fxptui.getexplorer;
    if isempty(me); treenode = []; return; end
    
    % protected model cannot provide any child node information
    if strcmpi(this.DAObject.ProtectedModel, 'on'); return; end;
    
    try
        subModelObj = get_param(this.DAObject.ModelName, 'Object'); 
    catch e %#ok<NASGU>
            % Model is probably not loaded anymore. Load the model and update the tree view.
        try
            load_system(this.DAObject.ModelName);
            subModelObj = get_param(this.DAObject.ModelName, 'Object'); 
            mdlNode = me.getFPTRoot.findChildNode(subModelObj);
            if isempty(mdlNode)
                addNodeToTree(me, subModelObj);
            end
        catch e  %#ok<NASGU>
                 % The model might not be on path. 
            treenode = [];
            return;
        end
    end
    treenode = me.getFPTRoot.findChildNode(subModelObj);
end

