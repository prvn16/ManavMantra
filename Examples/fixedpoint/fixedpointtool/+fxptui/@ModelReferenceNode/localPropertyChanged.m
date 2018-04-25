function localPropertyChanged(this, e)
% LOCALPROPERTYCHANGED Reacts to property change event on the dispatcher

%   Copyright 2013 The MathWorks, Inc.

if eq(e.Source,this.DAObject)
    isSrcProtectedModel = strcmpi(e.Source.ProtectedModel, 'on');
    me = fxptui.getexplorer;
    
    if isempty(me) || (~isSrcProtectedModel && isequal(e.Source.ModelName, this.PreviousModelName))
        % same model name do not trigger tree layout changes
        this.firePropertyChanged;
        return;
    end
        
    
    % Either new block is protected or switched to a different model
    if ~isSrcProtectedModel
        
        % reference from one model to another, neither is protected
        try
            load_system(e.Source.ModelName); 
            mdlObj = get_param(e.Source.ModelName,'Object');
            mdlNode = me.getFPTRoot.findChildNode(mdlObj);
            if isempty(mdlNode)
                addNodeToTree(me, mdlObj);
            end
            curNewModel = e.Source.ModelName; 
        catch exception %#ok<*NASGU>
            % Model is probably not on path - ignore and continue.
            curNewModel = [];
        end
    else
        % protected new model cannot be accessed by name
        curNewModel = [];
    end
    
    % Unpopulate the old model if it is not referenced anywhere
    try
        [refMdls, ~] = find_mdlrefs(me.getTopNode.DAObject.getFullName);
        if isempty(intersect(refMdls,this.PreviousModelName))
            removeModelNodes(me.getFPTRoot, this.PreviousModelName);
        end
    catch exception
        % One of the referenced models is not on path.
        if ~isempty(this.PreviousModelName) 
            foundMdlBlkUsage = checkModelInUse(me.getFPTRoot, this.PreviousModelName); 
            if ~foundMdlBlkUsage
                removeModelNodes(me.getFPTRoot, this.PreviousModelName);
            end
        end
    end
    this.PreviousModelName = curNewModel; 
    me.getFPTRoot.fireHierarchyChanged;  
    this.firePropertyChanged;
end
