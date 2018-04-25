function [hGroup, api, minSize] = createMultilineSelectGroup(this, hParent, title, strings, prefs)
%CREATEMULTILINESELECTGROUP Create a list to allow user selection.
%   This function will create a list control, which will allow the user
%   to pick one of several strings from a list.  Its layout is similar to 
%   createSingleEntryGroup.
%
%   Function arguments
%   ------------------
%   THIS: the gridPanel object instance.
%   HPARENT: The HG parent.
%   TITLE: The title for the group of strings.
%   STRINGS: The strings with which to fill the list.
%   PREFS: The tool preferences.

%   Copyright 2005-2013 The MathWorks, Inc.

    colorPrefs = this.fileTree.fileFrame.prefs.colorPrefs;

    % Create the GUI components.
    leftWidth  = prefs.subsetPanelContainer.leftWidth;
    rightWidth  = prefs.subsetPanelContainer.rightWidth;

    extraHeight = 4*prefs.charBtnHeight;
    pos1 = [prefs.charPad(1) prefs.charPad(2)+prefs.charLabelOffset+extraHeight ...
        leftWidth prefs.charTextHeight];
    pos2 = [2*prefs.charPad(1)+leftWidth prefs.charPad(2)...
        rightWidth prefs.charBtnHeight+extraHeight];
    totalSize = [3*prefs.charPad(1)+leftWidth+rightWidth...
        2*prefs.charPad(2)+prefs.charBtnHeight+extraHeight];

    % Create the 'Fields' uipanel
    hGroup = uipanel('Parent',hParent);
    label = uicontrol('parent',hGroup,...
        'Style','Text',...
        'String', title,...
        'Units', 'Characters',...
        'Position', pos1,...
        'HorizontalAlignment','right');
    editText = uicontrol('parent',hGroup,...
        'Style','listbox',...
        'String', strings,...
        'Units', 'Characters',...
        'Position', pos2,...
        'HorizontalAlignment','left',...
        'Tag', title,...
        'Callback', @(varargin)(this.buildImportCommand(false)) );
    set(hGroup,...
        'WidthLimits', [totalSize(1) totalSize(1)]*prefs.charExtent(1),...
        'HeightLimits', [totalSize(2) totalSize(2)]*prefs.charExtent(2));
    minSize = totalSize;

    % Create the API.
    api.reset = @reset;
    api.getSelectedString = @getSelectedString;
    api.setString = @setString;

    % ========================================================
    function reset()
        setString(strings);
        set(editText, 'Value', 1);
    end

    % ========================================================
    function str = getSelectedString()
        allStrings = get(editText, 'String');
        selected = get(editText, 'Value');
        str = allStrings{selected};
    end

    % ========================================================
    function setString(newString)
        strings = newString;
        set(editText, 'String', strings);
        set(editText, 'Value', 1);
    end

end

