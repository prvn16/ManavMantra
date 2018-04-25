function updateNodeInfo(this, hdfNode)
%UPDATENODEINFO Set the currentNode for this panel.
%   This will also make changes to the display, as necessary.
%   It is called when the user selects a different node,
%   for example.
%
%   Function arguments
%   ------------------
%   THIS: the object instance.
%   HDFNODE: the node that we are displaying.

%   Copyright 2005-2013 The MathWorks, Inc.

    if nargin>1
        this.currentNode = hdfNode;
    end

    fields = this.currentNode.nodeinfostruct.FieldNames;
    this.datafieldApi.setString(fields);

    this.levelApi.setString('1');
    
    this.boxApi.reset();
    this.recordApi.reset();
    this.timeApi.reset();
    
end
