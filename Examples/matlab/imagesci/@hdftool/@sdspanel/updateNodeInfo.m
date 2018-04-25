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

    rowLen = length(this.currentNode.nodeinfostruct.Dims);
    data = cell(rowLen,3);
    for n = 1:rowLen
        data{n,1} = num2str(1);
        data{n,2} = num2str(1);
        data{n,3} = num2str(this.currentNode.nodeinfostruct.Dims(n).Size);
    end
    
    this.tableApi.setTableData(data);
    
end
