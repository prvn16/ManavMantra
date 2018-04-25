function populate(this)
%POPULATE <short description>
%   OUT = POPULATE(ARGS) <long description>

%   Copyright 2010-2012 The MathWorks, Inc.

if ~this.TreeNode.isUnderMaskedSubsystem
    children = this.TreeNode.gethchildren;
    if (isempty(children))
        return;
    end
    this.HasChildren = true;
    n = length(children);
    for ci = 1:n
        subsys  = children(ci);
        if isa(subsys, 'Simulink.ModelReference')
            child = fxptui.BAEMdlBlkNode(subsys);
        else
            child = fxptui.BAETreeNode(subsys);
        end
        child.Parent = this;
        this.Children{ci} = child;
        connect(this,child,'down');
    end
end

%-------------------------------------------
% [EOF]
