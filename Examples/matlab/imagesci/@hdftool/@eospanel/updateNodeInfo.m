function updateNodeInfo(this, hdfNode)
%UPDATENODEINFO Set the CurrentNode for this panel.
%   Update any panels which might need to reflect this change.
%
%   Function arguments
%   ------------------
%   THIS: the eospanel object instance.
%   HDFNODE: the currently selected node.

%   Copyright 2005-2013 The MathWorks, Inc.

    if nargin>1
        this.currentNode = hdfNode;
    end

    % Refresh the relevant panel.
    activeIndex = this.subsetSelectionApi.getSelectedIndex();
    api = this.subsetApi{activeIndex};
    api.reset(this.currentNode.nodeinfostruct);
end
