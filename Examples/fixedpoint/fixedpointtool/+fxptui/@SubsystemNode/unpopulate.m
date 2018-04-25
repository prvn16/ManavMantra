function unpopulate(this)
% UNPOPULATE Removes the children from the hierarchy

% Copyright 2013-2014 The MathWorks, Inc.

    for idx = 1:this.ChildrenMap.getCount
        fxpblk = this.ChildrenMap.getDataByIndex(idx);
        if ~isempty(fxpblk) && isvalid(fxpblk)
            deleteListeners(fxpblk);
            disconnect(fxpblk);
            unpopulate(fxpblk);
            delete(fxpblk);
        end
    end
    for i = 1:this.ChildrenMap.getCount
        this.ChildrenMap.insert(this.ChildrenMap.getKeyByIndex(i),[]);
    end
    this.ChildrenMap.Clear;
    this.PropertyBag.clear;
    deleteListeners(this);
end

%--------------------------------------------------------------------------
function deleteListeners(fxpblk)
    for lIdx = 1:numel(fxpblk.SLListeners)
        delete(fxpblk.SLListeners(lIdx));
    end
    fxpblk.SLListeners = [];
end
