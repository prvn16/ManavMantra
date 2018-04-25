function isModelInUse = checkModelInUse(this, modelName)
% CHECKMODELINUSE Check if the model name is referred by other model nodes

% Copyright 2015 The MathWorks, Inc

isModelInUse = false;
if isempty(modelName)
    return; 
end
allChildren = this.children;
for idx = 1:numel(allChildren)
    % find model reference used in the modelNode
    modelNameList = getModelNames(this, allChildren(idx));
    if ~isempty(modelNameList) && any(ismember(modelNameList, modelName))
        isModelInUse = true;
        return;
    end
end

%---------------------------------------------------------
function modelNames = getModelNames(this, child)
modelNames = {};
if isempty(child)
    return;
end
if isa(child.daobject,'Simulink.ModelReference')
    modelNames = {child.daobject.ModelName};
    try
        mdlObj = get_param(modelNames{1},'Object');
        child = [];
        if isa(mdlObj,'DAStudio.Object')
            child = findobj(this.children,'-isa','fxptui.BAESubMdlNode','-and','daobject',mdlObj);
        end
    catch
        % this model has been closed or invalid
        % no additional information can be identified any more
        % return empty here
        modelNames = {};
        return;
    end
end
if ~isempty(child)
    ch = child.getHierarchicalChildren;
    for i = 1:length(ch)
        modelNames = [modelNames, getModelNames(this, ch(i))]; %#ok<AGROW>
    end
end