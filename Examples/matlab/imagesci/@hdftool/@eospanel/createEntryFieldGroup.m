function [hGroup, api, minSize] = createEntryFieldGroup(this, hParent, sz, defaultValue, labelStr, title, prefs)
%CREATEENTRYFIELDGROUP Creates a cluster of UI controls.
%   The UI controls (text edit fields) have a number of columns, and each column
%   has an associated name.  Currently, only one row of controls is
%   supported.
%
%   Function arguments
%   ------------------
%   THIS: the eospanel object instance.
%   HPARENT: the HG parent for the frame.
%   SZ: the [rows,cols] size of the entry fields.
%   DEFAULTVALUE: the default string value for each field.
%   LABELSTR: the set of column labels.
%   TITLE: the title of the set of field panels.
%   PREFS: the tool preferences.

%   Copyright 2005-2013 The MathWorks, Inc.

    colorPrefs = this.fileTree.fileFrame.prefs.colorPrefs;

    % Create the components.
    r = sz(1);
    c = sz(2);
    if r~=1
        error(message('MATLAB:imagesci:hdftool:tooManyEntryFieldRows'));
    end

    labels = zeros(1,c);
    editFields = zeros(r,c);

    hGroup = uipanel('Parent',hParent,...
        'Title', title,...
        'BorderType', 'etchedin');

    maxStringLen = 2 + max(cellfun('length', labelStr));
    textSize  = [maxStringLen prefs.charTextHeight];
    editSize  = [prefs.charEditWidth prefs.charBtnHeight];

    colWidth  = max(textSize(1), editSize(1)) + prefs.charPad(1);
    boxWidth  = c *colWidth + prefs.charPad(1);
    boxHeight = 3*prefs.charPad(2) + textSize(2) + r*editSize(2);

    for n = 1:c
        pos = [(n-1)*colWidth+prefs.charPad(1) r*editSize(2)+prefs.charPad(2) textSize(1) textSize(2)];
        labels(n) = uicontrol('Parent',hGroup,...
            'Style','Text',...
            'HorizontalAlignment','Left',...
            'String', labelStr{n},...
            'Units', 'characters',...
            'Position', pos,...
            'Callback', @(varargin)(this.buildImportCommand(false)) );
    end

    for m = 1:r
        for n = 1:c
            pos = [(n-1)*colWidth+prefs.charPad(1) ...
                   (m-1)*(editSize(2)+prefs.charPad(2))+prefs.charPad(2)/2 ...
                   editSize(1) ...
                   editSize(2)];
            editFields(m,n) = uicontrol('Parent',hGroup,...
                'HorizontalAlignment','Left',...
                'Style','Edit',...
                'Units', 'characters',...
                'Position', pos,...
                'BackgroundColor',prefs.colorPrefs.backgroundColor, ...
                'ForegroundColor',prefs.colorPrefs.textColor, ...
				'Tag', [title labelStr{n}],...
                'String', defaultValue,...
                'Callback', @(varargin)(this.buildImportCommand(false)) );
        end
    end

    minSize = [boxWidth boxHeight].*prefs.charExtent;
    set(hGroup,...
        'WidthLimits',[minSize(1) minSize(1)],...
        'HeightLimits',[minSize(2) minSize(2)]);

    % Create the API
    api.getValues = @getValues;
    api.reset     = @reset;

    %==============================================================
    function out = getValues()
        tmp = get(editFields,'String');
        [r,c] = size(tmp);
        out = zeros(r,c);

        for m = 1:r
            for n = 1:c
                out(m,n) = str2double(tmp(m,n));
            end
        end
    end

    %==============================================================
    function reset()
        set(editFields,'String',defaultValue);
    end

end

