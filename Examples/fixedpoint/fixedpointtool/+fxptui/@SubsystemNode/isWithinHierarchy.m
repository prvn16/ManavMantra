function b = isWithinHierarchy(this, daobject)
% isWithinStateflowHierarchy Returns true if the object is a child within
% the stateflow chart.

% Copyright 2013 MathWorks, Inc.

    b = false;
    for idx = 1:this.ChildrenMap.getCount
        blk = this.ChildrenMap.getDataByIndex(idx);
        if(isempty(blk))
            continue;
        end
        if isequal(blk.DAObject, daobject)
            b = true;
            break;
        else
            b = isWithinHierarchy(blk, daobject);
        end
        if b; break; end
    end
end
