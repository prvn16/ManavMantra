function selected_node = findNodeInHierarchyForObject(this, daobj)
% FINDPREVIOUSSELECTION Finds the previously selected tree node in the new SF hierarchy
    
% Copyright 2013 MathWorks, Inc
    
    selected_node = [];
    for idx = 1:this.ChildrenMap.getCount
        blk = this.ChildrenMap.getDataByIndex(idx);
        if(isempty(blk))
            continue;
        end
        if isequal(blk.DAObject, daobj)
            selected_node = blk;
            break;
        else
            selected_node = blk.findNodeInHierarchyForObject(daobj);
        end
        if isa(selected_node,'fxptui.AbstractObject'); break; end
    end
    if isempty(selected_node)
        selected_node = findobj(this,'DAObject',daobj);
    end
end
