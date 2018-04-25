function selectnode(h, name)
%SELECTNODE selects the specified system in the tree

%   Copyright 2007-2016 The MathWorks, Inc.

nodes = getchildnodes(h, h.getFPTRoot);
selected = selectTreeNodeWithName(h, nodes, name);
if ~selected
    try
        [isMasked, subsysObj] = fxptui.isUnderMaskedSubsystem(get_param(name,'Object'));
    catch 
        h.imme.selectTreeViewNode(h.getRoot);
        return;
    end
    if isMasked
        selected = selectTreeNodeWithName(h, nodes, subsysObj.getFullName);
    end
    if ~selected
        % If the system of interest is not present in the model hierarchy,
        % highlight the root node. 
        h.imme.selectTreeViewNode(h.getRoot);
    end
end

%--------------------------------------------------------------------------
function  selected = selectTreeNodeWithName(h, nodes, name)
idx = getsystembyname(nodes, name);
selected = false;
if ~isempty(idx)
    node = nodes(idx);
	% load complete hierarchy
    h.LoadCompleteHierarchy = true;

    if isa(node, 'fxptui.ModelNode')
        % For mcos tree
        % Select the tree node. To select the tree node, ME will by
        % default expand the tree. There is no need for FPT to expand
        % the tree to select the node.
        h.imme.selectTreeViewNode(node);
        selected = true;
    else
        % not model node
        
        % Select the tree node. To select the tree node, ME will by
        % default expand the tree. There is no need for FPT to expand
        % the tree to select the node.
        h.imme.selectTreeViewNode(h.getUDDNodeFromME(node));
        selected = true;
    end
    h.LoadCompleteHierarchy = false;
else
    % If the system of interest is not present in the model hierarchy,
    % highlight the root node. 
    h.imme.selectTreeViewNode(h.getRoot);
end
  
%--------------------------------------------------------------------------
function [si, ss] = getsystembyname(hc, name)
si = [];
ss = [];
name = fxptui.getPath(name);
for i=1:length(hc)
    if hc(i).isValid
        treeDAObject = hc(i).getDAObject;
        if ~isempty(treeDAObject)
            thisname = fxptui.getPath(treeDAObject.getFullName);
            if (strcmpi(thisname, name))
                si = i;
                ss = hc(i);
                break;
            end
        end
    end
end

%--------------------------------------------------------------------------
function children = getchildnodes(me, parent)

children = parent.getHierarchicalChildren;
if (isempty(children))
	return;
end
n = numel(children);
for chIdx = 1:n
  child = children(chIdx);
  newchildren = getchildnodes(me, child);
  children = [children newchildren]; 
end


%-------------------------------------------------------------------------
% [EOF]

% LocalWords:  fxptui
