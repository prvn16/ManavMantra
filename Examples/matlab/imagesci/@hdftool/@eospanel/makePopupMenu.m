function [hPopup, api, ctrl] = makePopupMenu(...
        this, hParent, createFrame, names, prefs)
%MAKEPUPUPMENU Creates a popupmenu for different subsetting methods.
%
%   Function arguments
%   ------------------
%   THIS: the eospanel object instance.
%   HPARENT: the HG parent for the frame.
%   CREATEFRAME: A function handle which should be able to create a frame 
%       corresponding to the selected radio button (passed by index).
%   NAMES: the radio button names.
%   PREFS: the tool preferences.

%   Copyright 2005-2013 The MathWorks, Inc.

    [hPopup, api, ctrl] = makePopup(this, hParent, names, ...
        @changeSubsetMethod, prefs);

    %==============================================
    function changeSubsetMethod(ctrl, event)
        activeIndex = get(ctrl, 'Value');
        oldIndex = find(this.subsetFrame);
        if activeIndex ~= oldIndex
            destroyFrame(oldIndex);
            createFrame(this, activeIndex);
            set(this.subsetFrame(activeIndex),'Visible','on');
            % Update the data
            istruct = this.currentNode.nodeinfostruct;
            api = this.subsetApi{activeIndex};
            api.reset(istruct);
            this.buildImportCommand(false);
        end
    end

    function destroyFrame(index)
        delete(this.subsetFrame(index));
        this.subsetFrame(index) = 0;
        this.subsetApi{index} = [];
    end

end

function [hPopup, api, ctrl] = makePopup(this, hParent, names, callback, prefs)
 
    colorPrefs = this.fileTree.fileFrame.prefs.colorPrefs;

    % Create a popup menu
    leftWidth   = prefs.subsetPanelContainer.leftWidth;
    rightWidth  = 30;
    pos1 = [prefs.charPad(1) prefs.charPad(2)+prefs.charLabelOffset leftWidth prefs.charTextHeight];
    pos2 = [2*prefs.charPad(1)+leftWidth prefs.charPad(2) rightWidth prefs.charBtnHeight];
    totalSize = [3*prefs.charPad(1)+leftWidth+rightWidth 2*prefs.charPad(2)+prefs.charBtnHeight];

    hPopup = uipanel('Parent', hParent);
    label = uicontrol('Parent',hPopup,...
        'Style','Text',...
        'String', getString(message('MATLAB:imagesci:hdftool:SubsettingMethod')),...
        'Units', 'Characters',...
        'Position', pos1,...
        'HorizontalAlignment','right');
    ctrl = uicontrol('Parent',hPopup,...
        'Style','popupMenu',...
        'String', names,...
        'Units', 'Characters',...
        'Position', pos2,...
        'BackgroundColor',prefs.colorPrefs.backgroundColor, ...
        'ForegroundColor',prefs.colorPrefs.textColor, ...
        'Value', 1,...
        'Tag', 'subsettingMethod',...
        'Callback', callback );
    set(hPopup,...
        'WidthLimits', [totalSize(1) totalSize(1)]*prefs.charExtent(1),...
        'HeightLimits', [totalSize(2) totalSize(2)]*prefs.charExtent(2));
    minSize = totalSize;
    
    % Create the API.
    api.getSelected        = @getSelected;
    api.getSelectedIndex   = @getSelectedIndex;
    api.setSelectedIndex   = @setSelectedIndex;
    api.reset              = @reset;

    %==============================================
    function reset(istruct)
    end

    %==============================================
    function out = getSelectedIndex()
        out = get(ctrl,'Value');
    end

    %==============================================
    function out = getSelected()
        selInd = getSelectedIndex();
        out = names{selInd};
    end

    %==============================================
    function setSelectedIndex(index)
        set(ctrl,'Value', index);
    end

end
