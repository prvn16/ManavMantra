function objectRemoved(this,e)
% OBJECTREMOVED Removes the child from the hierarchy

%   Copyright 2006-2015 The MathWorks, Inc.

    me = fxptui.getexplorer;
    if isempty(me); return; end;
    if ~strcmp('done', me.status); 
        return;
    end
    topModel = me.getTopNode.getDAObject.getFullName;
    if ~strcmpi(get_param(topModel,'SimulationStatus'),'stopped')
        return;
    end

    if(~this.isRemoveable);
        return;
    end
    
    child = e.Child;
    child = fxptui.filter(child);
    if(isempty(child)); return; end
    
    if this.ChildrenMap.isKey(child.Handle)
        fxpblk = this.ChildrenMap.getDataByKey(child.Handle);
        this.ChildrenMap.deleteDataByKey(child.Handle);
        if(isempty(fxpblk));
            return;
        end
        % If the deleted system was set as a SUD, then disable workflow
        % actions
        if isequal(fxpblk, me.ConversionNode)
           me.invalidateSUDSelection;
        end
        fxpblk.unpopulate;
        if isa(child,'Simulink.ModelReference')
            [refMdls, ~] = find_mdlrefs(topModel);
            if ~any(ismember(refMdls, child.ModelName))
                subModelNode = findobj(me.getFPTRoot.getModelNodes,'DAObject',get_param(child.ModelName,'Object'));
                if ~isempty(subModelNode)
                    cleanupReferencedModelNodes(this, subModelNode, refMdls);
                    % remove children before the parent
                    removeChild(me.getFPTRoot, subModelNode);

                end
            end
        end
        %update tree
        me.getFPTRoot.fireHierarchyChanged;
    end
    %update listview
    % event dispatcher does not work woth MCOS objects
    ed = DAStudio.EventDispatcher;
    if ~isempty(me)
        ed.broadcastEvent('ListChangedEvent', me.getTreeSelection);
    end
end

%--------------------------------------------------------------------------
function cleanupReferencedModelNodes(this, subModelNode, refMdls)
% Remove any models referenced from blocks contained within the submodel
% being removed.

me = fxptui.getexplorer;
mdlrefChild = findobj(subModelNode, '-isa','fxptui.ModelReferenceNode');
for kk = 1:numel(mdlrefChild)
    modelName = mdlrefChild(kk).getDAObject.ModelName;
    if ~any(ismember(refMdls, modelName))
        subModel = findobj(me.getFPTRoot.getModelNodes,'DAObject',get_param(mdlrefChild(kk).getDAObject.ModelName,'Object'));
        cleanupReferencedModelNodes(this, subModel, refMdls);
        removeChild(me.getFPTRoot, subModel);
    end
end
end