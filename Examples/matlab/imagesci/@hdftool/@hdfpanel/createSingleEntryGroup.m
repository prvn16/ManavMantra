function [hGroup, api, minSize] = createSingleEntryGroup(this, hParent, title, defaultValue, prefs)
%CREATESINGLEENTRYGROUP Create a titled edit box to allow user selection.
%   This function will create an edit control, which will allow the user
%   to input text.  Its layout is similar to createMultilineSelectGroup.
%
%   Function arguments
%   ------------------
%   THIS: the gridPanel object instance.
%   HPARENT: The HG parent.
%   TITLE: The title of the control (or the type of input requested).
%   DEFAULTVALUE: The default edit box value.
%   PREFS: The tool preferences.

%   Copyright 2005-2013 The MathWorks, Inc.

    colorPrefs = this.fileTree.fileFrame.prefs.colorPrefs;

    % Create the GUI components
    leftWidth  = prefs.subsetPanelContainer.leftWidth;
    rightWidth  = prefs.subsetPanelContainer.rightWidth;
    pos1 = [prefs.charPad(1) prefs.charPad(2)+prefs.charLabelOffset leftWidth prefs.charTextHeight];
    pos2 = [2*prefs.charPad(1)+leftWidth prefs.charPad(2) rightWidth prefs.charBtnHeight];
    totalSize = [3*prefs.charPad(1)+leftWidth+rightWidth prefs.charPad(2)+prefs.charBtnHeight];

    hGroup = uipanel('Parent',hParent);
    label = uicontrol('Parent',hGroup,...
        'Style','Text',...
        'String', title,...
        'Units', 'Characters',...
        'Position', pos1,...
        'HorizontalAlignment','right');
    editText = uicontrol('Parent',hGroup,...
        'Style','Edit',...
        'String', defaultValue,...
        'Units', 'Characters',...
        'BackgroundColor',prefs.colorPrefs.backgroundColor, ...
        'ForegroundColor',prefs.colorPrefs.textColor, ...
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
    function reset(istruct)
        setString(defaultValue);
    end

    % ========================================================
    function str = getSelectedString()
        str = get(editText, 'String');
    end

    % ========================================================
    function setString(newString)
        set(editText, 'String', newString);
    end

end
