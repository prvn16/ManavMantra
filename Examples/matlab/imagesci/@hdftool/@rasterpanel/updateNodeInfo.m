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

    type = this.currentNode.nodeinfostruct.Type;
    switch type
        case '8-Bit Raster Image'
            set([this.editHandle, this.textHandle],'Visible','on');
            set(this.editHandle,'String',[this.filetree.wsvarname '_map']);
        case '24-Bit Raster Image'
            set([this.editHandle, this.textHandle],'Visible','off');
            set(this.editHandle,'String','');
            % Since we have no parameters, disable the reset button.
            resetButton = findobj(this.mainPanel, 'tag', 'resetSelectionParameters');
            set(resetButton, 'enable', 'on');
    end
end
