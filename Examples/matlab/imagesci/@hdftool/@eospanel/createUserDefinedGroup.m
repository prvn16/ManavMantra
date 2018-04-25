function [hGroup, api, minSize] = createUserDefinedGroup(...
        this, hParent, defaultValue, title, prefs)
%CREATEUSERDEFINEDGROUP Creates the uipanels for "user-defined" subsetting method.
%   The UI controls correspond to list boxes to select the dimension,
%   and two edit boxes which specify the minimum and maximum values.
%
%   Function arguments
%   ------------------
%   THIS: the eospanel object instance.
%   HPARENT: the HG parent for the frame.
%   DEFAULTVALUE: the default value.
%   TITLE: the title of this frame.
%   PREFS: the tool preferences.

%   Copyright 2005-2013 The MathWorks, Inc.


    % Create the components.
    istruct = this.CurrentNode.nodeinfostruct;
    dimNamePopup = [];
    minEdit      = [];
    maxEdit      = [];

    hGroup = uipanel('Parent',hParent,...
        'Title', title,...
        'Bordertype', 'etchedin');

    len = length(istruct.Dims);
    dimNames = cell(1,len);
    for n = 1:len
	    % Do not translate, these can be used in command strings.
        dimNames{n} = getString(message('MATLAB:imagesci:hdftool:userDefinedDim',istruct.Dims(n).Name));
    end
    % Increase the length by one if there is a vertical subset.
    if isfield(istruct,'vertical') && ~isempty(istruct.vertical)
        len = len+1;
        dimNames{len} = istruct.vertical;
    end

    hgrid = uiflowcontainer('v0', 'Parent',hGroup,...
                'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
                'FlowDirection','TopDown');

    selectWidth = 16;
    valueWidth = 8;
    xStart(1) = 0;
    xStart(2) = xStart(1) + selectWidth+prefs.charPad(1);
    xStart(3) = xStart(2) + valueWidth+prefs.charPad(1);

    text = uipanel('parent', hgrid);
    pos = [prefs.charPad(1) 0 0 2*prefs.charTextHeight];
    dimLabel = uicontrol('Parent',text,'Style','Text',...
        'HorizontalAlignment','Left',...
        'String', getString(message('MATLAB:imagesci:hdftool:userDefinedDimensionOrFieldName')), ...
        'Units', 'Character',...
        'Position', pos + [xStart(1) 0 selectWidth 0]); %#ok<NASGU>
    minLabel = uicontrol('Parent',text,'Style','Text',...
        'HorizontalAlignment','Left',...
        'String', getString(message('MATLAB:imagesci:hdftool:userDefinedMin')), ...
        'Units', 'Character',...
        'Position', pos + [xStart(2) 0 valueWidth 0]); %#ok<NASGU>
    maxLabel = uicontrol('Parent',text,'Style','Text',...
        'HorizontalAlignment','Left',...
        'String', getString(message('MATLAB:imagesci:hdftool:userDefinedMax')), ...
        'Units', 'Character',...
        'Position', pos + [xStart(3) 0 valueWidth 0]); %#ok<NASGU>
    height = 2*prefs.charTextHeight + prefs.charPad(2)/2;
    totalHeight = height;
    set(text,...
        'HeightLimits',[height height]*prefs.charExtent(2));

    for m = 1:len
        text = uipanel('parent', hgrid);
        pos = [prefs.charPad(1) prefs.charPad(2)/2 0 prefs.charBtnHeight];
        dimNamePopup(m) = uicontrol('Parent',text,...
            'Style','popupmenu',...
            'String',dimNames,...
            'HorizontalAlignment','left',...
            'Units', 'Character',...
            'BackgroundColor',prefs.colorPrefs.backgroundColor, ...
            'ForegroundColor',prefs.colorPrefs.textColor, ...
            'Position', pos + [xStart(1) 0 selectWidth 0],...
            'Tag', ['dim' num2str(m)],...
            'Callback', @(varargin)(this.buildImportCommand(false)) );
        minEdit(m) = uicontrol('Parent',text,...
            'HorizontalAlignment','Left',...
            'Style','edit',...
            'Units', 'Character',...
            'BackgroundColor',prefs.colorPrefs.backgroundColor, ...
            'ForegroundColor',prefs.colorPrefs.textColor, ...
            'Position', pos + [xStart(2) 0 valueWidth 0],...
            'String', defaultValue,...
            'Tag', ['min' num2str(m)],...
            'Callback', @(varargin)(this.buildImportCommand(false)) );
        maxEdit(m) = uicontrol('Parent',text,...
            'HorizontalAlignment','Left',...
            'Style','edit',...
            'Units', 'Character',...
            'BackgroundColor',prefs.colorPrefs.backgroundColor, ...
            'ForegroundColor',prefs.colorPrefs.textColor, ...
            'Position', pos + [xStart(3) 0 valueWidth 0],...
            'String', defaultValue,...
            'Tag', ['max' num2str(m)],...
            'Callback', @(varargin)(this.buildImportCommand(false)) );
        height = prefs.charBtnHeight + prefs.charPad(2);
        totalHeight = totalHeight + height;
        set(text,...
            'HeightLimits',[height height]*prefs.charExtent(2));
    end

    minWidth  = xStart(3) + valueWidth + 2*prefs.charPad(1);
    minHeight = totalHeight+ 2*prefs.charPad(2);

    minSize = [minWidth, minHeight].*prefs.charExtent;

    set(hGroup, 'WidthLimits', [minSize(1) minSize(1)],...
        'HeightLimits', [minSize(2) minSize(2)] );

    % Create the API
    api.getSelectedFieldNames  = @getSelectedFieldNames;
    api.getSelectedFieldValues = @getSelectedFieldValues;
    api.getMinValues           = @getMinValues;
    api.getMaxValues           = @getMaxValues;
    api.setInfoStruct          = @setInfoStruct;
    api.getLength              = @getLength;
    api.reset                  = @reset;

    %=================================================
    function out = getSelectedFieldNames()
        % Index into the field names using the selected values
        % of the popup controls.
        str = get(dimNamePopup(1),'String');
        out = str(flipud(getSelectedFieldValues));
    end

    %=================================================
    function out = getSelectedFieldValues()
        tmp = get(dimNamePopup,'Value');
        if iscell(tmp)
            out = cell2mat(tmp);
            out = flipud(out);
        else
            out = tmp;
        end
    end

    %=================================================
    function out = getMinValues()
        out = get(minEdit,'String');
    end

    %=================================================
    function out = getMaxValues()
        out = get(maxEdit,'String');
    end

    %=================================================
    function reset()
        set([maxEdit,minEdit],'String',defaultValue);
        set(dimNamePopup,'Value',1);
    end

    %=================================================
    function setInfoStruct(istruct)
        newLen = length(istruct.Dims);
        dimNames = cell(1,len);
        for nn = 1:newLen
            dimNames{nn} = ['DIM:',istruct.Dims(nn).Name];
        end
        % Increase the length by one if there is a vertical subset.
        if isfield(istruct,'vertical') && ~isempty(istruct.vertical)
            len = len+1;
            dimNames{len} = istruct.vertical;
        end
        set(dimNamePopup,'String',dimNames);
        set([minEdit;maxEdit],'String',defaultValue);
    end

    %=================================================
    function out = getLength()
        out = len;
    end
end
