function treenode = getSupportedParentTreeNode(this)
% GETSUPPORTEDPARENTTREENODE Get the closest supported parent node for an
% action.

% Copyright 2013-2014 The MathWorks, Inc.

treenode = this;
if isNodeSupported(this); return; end
me = fxptui.getexplorer;
FPTRoot = me.getFPTRoot;
parent = this.DAObject;
while ~isa(parent,'Simulink.BlockDiagram') && ~isNodeSupported(treenode)
    parent = treenode.DAObject.getParent;
    switch class(parent)
        case {'Stateflow.EMChart',...
                'Stateflow.Chart', ...
                'Stateflow.LinkChart', ...
                'Stateflow.TruthTableChart', ...
                'Stateflow.ReactiveTestingTableChart', ...
                'Stateflow.StateTransitionTableChart'}
            parent = parent.up;
        otherwise
    end
    treenode = FPTRoot.findNodeInCompleteHierarchy(parent);
end
