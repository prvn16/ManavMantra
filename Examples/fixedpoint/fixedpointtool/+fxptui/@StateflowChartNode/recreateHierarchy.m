function recreateHierarchy(this, e)
% RECREATEHIERARCHY Recreate the stateflow hierarchy on a hierarchy changed event

% Copyright 2013 MathWorks, Inc

    if ~isa(this.DAObject,'Simulink.SubSystem')
        return;
    end
    %Get the SF object that this node points to.
    myobj = fxptds.getSFChartObject(this.DAObject);
    %if our chart is not the one who's hierarchy changed, return
    if(~isequal(myobj, e.Source)); return; end
    
    % Get the previously selected node to reselect the node after the tree
    % hierarchy is built. 
    me = fxptui.getexplorer;
    if isempty(me); return; end
    
    if ~strcmpi(get_param(me.getTopNode.getDAObject.getFullName,'SimulationStatus'),'stopped')
        return;
    end
     
    currentSelNode = me.getSelectedTreeNode;
    me.sleep;
    if ~isempty(currentSelNode)
        daobj = currentSelNode.getDAObject;
    else
        daobj = [];
    end
    
    for idx = 1:this.ChildrenMap.getCount
        blk = this.ChildrenMap.getDataByIndex(idx);
        if(isempty(blk))
            continue;
        end
        unpopulate(blk);
        delete(blk);
    end
    
    this.ChildrenMap.Clear;
    this.populate;
 
    me.wake;
    % Get the previously selected node after the tree is re-populated. If
    % the selected node is valid, that means it was not part of the SF
    % hierarchy.
    if ~isempty(daobj) && (~isa(currentSelNode,'fxptds.AbstractObject') || ...
            (isa(currentSelNode,'fxptds.AbstractObject') && ~currentSelNode.isvalid))
        mcosNode = this.findNodeInHierarchyForObject(daobj);
        if isa(mcosNode,'fxptds.AbstractObject') && ~isempty(mcosNode) && mcosNode.isvalid
            me.imme.selectTreeViewNode(mcosNode);
        end
    end
end
