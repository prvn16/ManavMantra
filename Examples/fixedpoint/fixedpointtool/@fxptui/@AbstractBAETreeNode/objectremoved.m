function objectremoved(this,~,e)
%OBJECTREMOVED <short description>
%   OUT = OBJECTREMOVED(ARGS) <long description>

%   Copyright 2010-2016 The MathWorks, Inc.

%if(~this.TreeNode.isremoveable);return;end
child = e.Child;
child = fxptui.filter(child);
if(isempty(child)); return; end


% Get the node for the removed child
node = find(this,'daobject',child,'-depth',inf); %#ok<GTARG>
if ~isempty(node)
    parent = node(1).Parent;
    if ~isempty(parent)
        for i = 1:length(parent.Children)
            if isequal(parent.Children{i}, node)
                parent.Children{i} = [];
                break;
            end
        end
    end
    % Disconnect the node from the tree hierarchy.
    disconnect(node);
    node.unpopulate;
    
     if isa(child,'Simulink.ModelReference')
         bae = fxptui.BAExplorer.getBAExplorer;
         [refMdls, ~] = find_mdlrefs(bae.getTopNode.daobject.getFullName);
         if ~any(ismember(refMdls, child.ModelName))
             try
                 modelObj = get_param(child.ModelName,'Object');
                 subModelNode = find(bae.getRoot.children, '-isa', 'fxptui.BAESubMdlNode', 'daobject',modelObj); %#ok<GTARG>
                 if ~isempty(subModelNode)
                     cleanupReferencedModelNodes(this, subModelNode, refMdls);
                     % remove children before the parent
                     removeChild(bae.getRoot, subModelNode);
                 end
             catch
                 % model is not loaded. skip
             end
         end
     end

    %update tree
    ed = DAStudio.EventDispatcher;
    ed.broadcastEvent('ChildRemovedEvent', this, node);
end  

%--------------------------------------------------------------------------
function cleanupReferencedModelNodes(this, subModelNode, refMdls)

bae = fxptui.BAExplorer.getBAExplorer;
mdlrefChild = findobj(subModelNode, '-isa','fxptui.BAEMdlBlkNode');
for kk = 1:numel(mdlrefChild)
    modelName = mdlrefChild(kk).daobject.ModelName; 
    if ~any(ismember(refMdls, modelName))
        try
            modelObj = get_param(modelName,'Object');
            subModel = findobj(bae.getRoot.children,'daobject',modelObj);
            cleanupReferencedModelNodes(this, subModel, refMdls);
            removeChild(bae.getRoot, subModel);
        catch
            % model is not loaded.
        end
    end
end



% [EOF]
