function children = getHierarchicalChildren(this)
%GETHIERARCHICALCHILDREN Return the children for this node
%   OUT = GETHIERARCHICALCHILDREN(ARGS) <long description>

%   Copyright 2011 The MathWorks, Inc.

children = [];
if iscell(this.Children)
    isChildEmpty = cellfun(@isempty,this.Children);
    if all(isChildEmpty)
        children = [];
        return;
    end
else
    if isempty(this.Children); children = []; return; end;
end
cnt = 1;
for i = 1:length(this.Children)
    thisChild = this.Children{i};
    if ~isempty(thisChild)
        if ~isa(thisChild.daobject,'DAStudio.Object')
            % The block that this object was referring to was cleared from
            % memory and should no longer be reflected in the UI.
            unpopulate(thisChild);
            %update tree
            ed = DAStudio.EventDispatcher;
            %update tree
            ed.broadcastEvent('ChildRemovedEvent', this, thisChild);
            this.Children{i} = [];
            continue;
        else
            if isempty(children)
                children = this.Children{i};
            else
                children(cnt) = this.Children{i}; %#ok<AGROW>
            end
            cnt = cnt+1;
        end
    end
end

% [EOF]
