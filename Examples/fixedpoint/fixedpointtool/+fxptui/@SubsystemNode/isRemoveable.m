function b = isRemoveable(~) 
% ISREMOVEABLE True if the node can be removed from the tree

% Copyright 2013 MathWorks, Inc.

    b = false;
    me = fxptui.getexplorer;
    
    if isempty(me); return; end
    
    root = me.getTopNode;
    
    if (isempty(root) || ~isa(root.DAObject, 'DAStudio.Object'))
        return; 
    else
        isClosing = root.isClosing;
    end
    
    if(isempty(root.DAObject) || isClosing)
        return;
    end
    
    if(~strcmpi('stopped', root.DAObject.SimulationStatus))
        return;
    end
    b = true;
end

