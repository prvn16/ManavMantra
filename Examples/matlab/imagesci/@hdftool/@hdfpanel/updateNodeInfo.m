function updateNodeInfo(this, hdfNode)
%UPDATENODEINFO Set the currentNode for this panel.
%   This is necessary when the selected node changes, for example.

%   Copyright 2005-2013 The MathWorks, Inc.
  
    if nargin>1
        this.currentNode = hdfNode;
    end

end
