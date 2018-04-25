function ret=plotedittoolbar(hfig,varargin)
%PLOTEDITTOOLBAR Annotation toolbar.

%   Copyright 1984-2014 The MathWorks, Inc.

Udata = getUdata(hfig);
r = [];

if nargin==1
    r = plotedittoolbar(hfig,'show');
    arg = '';
elseif nargin==2
    arg = lower(varargin{1});
    if ~strcmp(arg, 'init') && isempty(Udata)
        r = plotedittoolbar(hfig,'init');
        Udata = getUdata(hfig);
    end
elseif nargin==3
    arg = 'settoggprop';
elseif nargin==4
    arg = 'set';
else
    return;
end
emptyUdata = isempty(Udata);
switch arg
    case 'init'
        stb = findall(hfig, 'tag', 'PlotEditToolBar');
        if isempty(stb)
            r = createToolbar(hfig);
        end
        initUdata(hfig);
        Udata = getUdata(hfig);
        setUdata(hfig,Udata)
    case 'show'
        set(Udata.mainToolbarHandle, 'visible', 'on');
    case 'hide'
        set(Udata.mainToolbarHandle, 'visible', 'off');
    case 'toggle'
        if emptyUdata
            plotedittoolbar(hfig,'init');
        else
            h = Udata.mainToolbarHandle;
            val = get(h,'visible');
            if strcmpi(val,'off')
                set(h,'visible','on');
            else
                set(h,'visible','off');
            end
        end
    case 'getvisible'
        if isempty(Udata)
            r = 0;
        else
            h = Udata.mainToolbarHandle;
            r = strcmp(get(h, 'visible'), 'on');
        end
    case 'close'
        if ishghandle(Udata.mainToolbarHandle)
            delete(Udata.mainToolbarHandle);
        end
        setUdata(hfig,[]);
    case 'settoggprop'
        if isnumeric(varargin{2}) || ...
                (ischar(varargin{2}) && ...
                (strcmpi(varargin{2},'none') || ...
                strcmpi(varargin{2},'auto') || ...
                strcmpi(varargin{2},'flat') || ...
                strcmpi(varargin{2},'interp')))
            % set cdata
            setColortoggleCdata(hfig,varargin{1},varargin{2})
        elseif ischar(varargin{2})
            % set tooltip
            setToggleTooltip(hfig,varargin{1},varargin{2})
        end
    case 'set'
        % ploteditToolbar(item,prop,onoff);
        setToolbarItemProperties(hfig,varargin{:})
    otherwise
        processItem(hfig,arg);
end

if nargout>0
    ret = r;
end
%--------------------------------------------------------------%
function h=createToolbar(hfig)

hPlotEdit = plotedit(hfig,'getmode');
hMode = hPlotEdit.ModeStateData.PlotSelectMode;

h = uitoolbar(hfig, 'HandleVisibility','off');
Udata.mainToolbarHandle = h;
iconroot = [toolboxdir('matlab') '/icons/'];
uicprops.Parent = h;
uicprops.HandleVisibility = 'off';

% Face Color
uicprops.ClickedCallback = '';
uicprops.OnCallback = {@localProcessItem,hMode,'FaceColor'};
uicprops.OffCallback = '';
uicprops.CreateFcn = '';
uicprops.ToolTip = getString(message('MATLAB:uistring:plotedittoolbar:FaceColor'));
uicprops.Tag = 'figToolScribeFaceColor';
uicprops.CData = loadicon([iconroot 'tool_shape_fill_face.png']);
utogg = uitoggletool(uicprops);

% Edge/Line Color
uicprops.ClickedCallback = '';
uicprops.OnCallback = {@localProcessItem,hMode,'EdgeColor'};
uicprops.OffCallback = '';
uicprops.CreateFcn = '';
uicprops.ToolTip = getString(message('MATLAB:uistring:plotedittoolbar:EdgeColor'));
uicprops.Tag = 'figToolScribeEdgeColor';
uicprops.CData = loadicon([iconroot 'tool_shape_fill_stroke.png']);
utogg(end+1) = uitoggletool(uicprops);

% Text Color
uicprops.ClickedCallback = '';
uicprops.OnCallback = {@localProcessItem,hMode,'TextColor'};
uicprops.OffCallback = '';
uicprops.CreateFcn = '';
uicprops.ToolTip = getString(message('MATLAB:uistring:plotedittoolbar:TextColor'));
uicprops.Tag = 'figToolScribeTextColor';
uicprops.CData = loadicon([iconroot 'tool_font.png']);
utogg(end+1) = uitoggletool(uicprops,'Separator','on');

% Font
uicprops.ClickedCallback = '';
uicprops.OnCallback = {@localProcessItem,hMode,'TextFont'};
uicprops.OffCallback = '';
uicprops.CreateFcn = '';
uicprops.ToolTip = getString(message('MATLAB:uistring:plotedittoolbar:Font'));
uicprops.Tag = 'figToolScribeTextFont';
uicprops.CData = loadicon([iconroot 'tool_font.png']);
utogg(end+1) = uitoggletool(uicprops);

% Text Bold
uicprops.ClickedCallback = '';
uicprops.OnCallback = {@localProcessItem,hMode,'TextBold'};
uicprops.OffCallback = {@localProcessItem,hMode,'TextNoBold'};
uicprops.CreateFcn = '';
uicprops.ToolTip = getString(message('MATLAB:uistring:plotedittoolbar:Bold'));
uicprops.Tag = 'figToolScribeTextBold';
uicprops.CData = loadicon([iconroot 'tool_font_bold.png']);
utogg(end+1) = uitoggletool(uicprops,'Separator','on');

% Text Italic
uicprops.ClickedCallback = '';
uicprops.OnCallback = {@localProcessItem,hMode,'TextItalic'};
uicprops.OffCallback = {@localProcessItem,hMode,'TextNoItalic'};
uicprops.CreateFcn = '';
uicprops.ToolTip = getString(message('MATLAB:uistring:plotedittoolbar:Italic'));
uicprops.Tag = 'figToolScribeTextItalic';
uicprops.CData = loadicon([iconroot 'tool_font_italic.png']);
utogg(end+1) = uitoggletool(uicprops);

% Left Align
uicprops.ClickedCallback = '';
uicprops.OnCallback = {@localProcessItem,hMode,'TextLeft'};
uicprops.OffCallback = '';
uicprops.CreateFcn = '';
uicprops.ToolTip = getString(message('MATLAB:uistring:plotedittoolbar:AlignLeft'));
uicprops.Tag = 'figToolScribeLeftTextAlign';
uicprops.CData = loadicon([iconroot 'tool_text_align_left.png']);
utogg(end+1) = uitoggletool(uicprops,'Separator','on');

% Center Align
uicprops.ClickedCallback = '';
uicprops.OnCallback = {@localProcessItem,hMode,'TextCenter'};
uicprops.OffCallback = '';
uicprops.CreateFcn = '';
uicprops.ToolTip = getString(message('MATLAB:uistring:plotedittoolbar:AlignCenter'));
uicprops.Tag = 'figToolScribeCenterTextAlign';
uicprops.CData = loadicon([iconroot 'tool_text_align_center.png']);
utogg(end+1) = uitoggletool(uicprops);

% Right Align
uicprops.ClickedCallback = '';
uicprops.OnCallback = {@localProcessItem,hMode,'TextRight'};
uicprops.OffCallback = '';
uicprops.CreateFcn = '';
uicprops.ToolTip = getString(message('MATLAB:uistring:plotedittoolbar:AlignRight'));
uicprops.Tag = 'figToolScribeRightTextAlign';
uicprops.CData = loadicon([iconroot 'tool_text_align_right.png']);
utogg(end+1) = uitoggletool(uicprops);

% Standard scribe annotations
u =uitoolfactory(h,'Annotation.InsertLine');
set(u,'Separator','on');
uitoolfactory(h,'Annotation.InsertArrow');
uitoolfactory(h,'Annotation.InsertDoubleArrow');
uitoolfactory(h,'Annotation.InsertTextArrow');
uitoolfactory(h,'Annotation.InsertTextbox');
uitoolfactory(h,'Annotation.InsertRectangle');
uitoolfactory(h,'Annotation.InsertEllipse');
% Standard scribe actions
u = uitoolfactory(h,'Annotation.Pin');
set(u,'Separator','on');
uitoolfactory(h,'Annotation.AlignDistribute');

% Save handle arrays
Udata.handles = utogg;

% Add a listener on the selected object state on the plot manager:
% Send an event broadcasting the change in object selection:
plotmgr = feval(graph2dhelper('getplotmanager'));
mcosListeners = event.listener(plotmgr,'PlotSelectionChange',@(obj,evd)(localUpdateToolbar(obj,evd,hMode)));
mcosListeners.Enabled = strcmpi(hMode.Enable,'on');
if isa(hMode,'matlab.uitools.internal.uimode')
    mcosListeners(end+1) = event.proplistener(hMode,findprop(hMode,'Enable'),'PostSet',@(obj,evd)(localEnableListener(obj,evd,mcosListeners(1),hMode)));
end
Udata.mcosmodeListeners = mcosListeners;
setUdata(hfig,Udata);

set(Udata.mainToolbarHandle, 'tag', 'PlotEditToolBar', 'visible', 'off','serializable','off');

% Initialize the toolbar based on the selected objects
localUpdateToolbar([],[],hMode);

%--------------------------------------------------------------%
function localUpdateToolbar(~,~,hMode)
% Every time the selection changes, update the toolbar

% First, disable all the toolbar items. We will reenable them based on the
% selected objects.
hFig = hMode.FigureHandle;
setToolbarItemProperties(hFig,'all',{'Enable','State'},{'off','off'});

% Deal with the pin button: If nothing pinnable exists in the figure, then
% disable the button.
hPinButton = uigettool(hFig,'Annotation.Pin');
% We define a pinnable object as a child of the annotation layer:
[hScribeLayer, hPanelScribeLayers] = graph2dhelper('findAllScribeLayers',hFig);
hScribeLayer = [hScribeLayer hPanelScribeLayers];
pinBtnState = 'off';
for k=1:length(hScribeLayer)
    if ~isempty(hScribeLayer(k).Children)
        pinBtnState = 'on';
        break;
    end
end
set(hPinButton,'Enable',pinBtnState );

% If the mode is not active, return early
if ~strcmpi(hMode.Enable,'on')
    return;
end

% If nothing is selected, bail out:
hSelected = getselectobjects(hFig);
if isempty(hSelected)
    return;
end

% If the selected objects are not homogeneous, bail out.
if ~hMode.ModeStateData.IsHomogeneous
    return;
end
% Use the last object in the selected item list to determine initial
% values:
hObj = hSelected(end);

% Face Color:
[propNames, toolTipName] = localGetPropNames(hObj,'FaceColor');
if all(cellfun('isempty',propNames))
    setToolbarItemProperties(hFig,'FaceColor',{'State','Enable'},{'off','off'});
else
    setColortoggleCdata(hFig,'FaceColor',get(hObj,propNames{1}));
    setToolbarItemProperties(hFig,'FaceColor',{'State','Enable',...
        'ToolTipString'},{'off','on',toolTipName});
end
% Edge Color:
[propNames, toolTipName] = localGetPropNames(hObj,'EdgeColor');
if all(cellfun('isempty',propNames))
    setToolbarItemProperties(hFig,'EdgeColor',{'State','Enable'},{'off','off'});
else
    setColortoggleCdata(hFig,'EdgeColor',get(hObj,propNames{1}));
    setToolbarItemProperties(hFig,'EdgeColor',{'State','Enable',...
        'ToolTipString'},{'off','on',toolTipName});
end
% Text Color:
[propNames, toolTipName] = localGetPropNames(hObj,'TextColor');
if all(cellfun('isempty',propNames))
    setToolbarItemProperties(hFig,'TextColor',{'State','Enable'},{'off','off'});
else
    setColortoggleCdata(hFig,'TextColor',get(hObj,propNames{1}));
    setToolbarItemProperties(hFig,'TextColor',{'State','Enable',...
        'ToolTipString'},{'off','on',toolTipName});
end
% Font:
[propNames, toolTipName] = localGetPropNames(hObj,'Font');
if all(cellfun('isempty',propNames))
    setToolbarItemProperties(hFig,'Font',{'State','Enable'},{'off','off'});
else
    setToolbarItemProperties(hFig,'Font',{'State','Enable',...
        'ToolTipString'},{'off','on',toolTipName});
end
% Bold:
[propNames, toolTipName] = localGetPropNames(hObj,'Bold');
if all(cellfun('isempty',propNames))
    setToolbarItemProperties(hFig,'Bold',{'State','Enable'},{'off','off'});
else
    if strcmpi(get(hObj,propNames{1}),'Bold')
        buttonState = 'on';
    else
        buttonState = 'off';
    end
    setToolbarItemProperties(hFig,'Bold',{'State','Enable',...
        'ToolTipString'},{buttonState,'on',toolTipName});
end
% Italic:
[propNames, toolTipName] = localGetPropNames(hObj,'Italic');
if isempty(propNames)
    setToolbarItemProperties(hFig,'Italic',{'State','Enable'},{'off','off'});
else
    if strcmpi(get(hObj,propNames{1}),'Italic')
        buttonState = 'on';
    else
        buttonState = 'off';
    end
    setToolbarItemProperties(hFig,'Italic',{'State','Enable',...
        'ToolTipString'},{buttonState,'on',toolTipName});
end
% Alignment Properties:
[propNames, toolTipName] = localGetPropNames(hObj,'LeftAlign');
if all(cellfun('isempty',propNames))
    setToolbarItemProperties(hFig,'LeftAlign',{'State','Enable'},{'off','off'});
else
    if strcmpi(get(hObj,propNames{1}),'left')
        buttonState = 'on';
    else
        buttonState = 'off';
    end
    setToolbarItemProperties(hFig,'LeftAlign',{'State','Enable',...
        'ToolTipString'},{buttonState,'on',toolTipName});
end
[propNames, toolTipName] = localGetPropNames(hObj,'RightAlign');
if all(cellfun('isempty',propNames))
    setToolbarItemProperties(hFig,'RightAlign',{'State','Enable'},{'off','off'});
else
    if strcmpi(get(hObj,propNames{1}),'right')
        buttonState = 'on';
    else
        buttonState = 'off';
    end
    setToolbarItemProperties(hFig,'RightAlign',{'State','Enable',...
        'ToolTipString'},{buttonState,'on',toolTipName});
end
[propNames, toolTipName] = localGetPropNames(hObj,'CenterAlign');
if all(cellfun('isempty',propNames))
    setToolbarItemProperties(hFig,'CenterAlign',{'State','Enable'},{'off','off'});
else
    if strcmpi(get(hObj,propNames{1}),'center')
        buttonState = 'on';
    else
        buttonState = 'off';
    end
    setToolbarItemProperties(hFig,'CenterAlign',{'State','Enable',...
        'ToolTipString'},{buttonState,'on',toolTipName});
end

%--------------------------------------------------------------%
function localEnableListener(obj,evd,eListener,hMode) %#ok<INUSL>
% Enable or disable the selection listener based on the state of Plot
% Select Mode.
if ishandle(hMode)
    eListener.Enabled = evd.NewValue;
    % Make sure the toolbar is in sync when the mode is on and toolbar items
    % are disabled when the mode is off.
    if strcmpi(evd.NewValue,'on')
        localUpdateToolbar([],[],hMode);
    else
        setToolbarItemProperties(hMode.FigureHandle,'all',{'Enable','State'},{'off','off'});
    end
elseif isobject(hMode)
    % eventdata will not have the NewValue for the mcos. Settign the Enable flag directly from the mode object.
    eListener.Enabled = strcmpi(hMode.Enable,'on');
    if strcmpi(hMode.Enable,'on')
        localUpdateToolbar([],[],hMode);
    else
        setToolbarItemProperties(hMode.FigureHandle,'all',{'Enable','State'},{'off','off'});
    end
end

%--------------------------------------------------------------%
function [propNames, description] = localGetPropNames(hObj,item)
% Given an object and a toolbar button property, return the property name
% (if any) and the property description to be used
propNames = {};
description = '';

% For MCOS graphics scribe objects, use the getPlotEditToolbarProp method
% to obtain the equivalent property name.
if isa(hObj,'matlab.graphics.shape.internal.ScribeObject')
    [propNames,description] = hObj.getPlotEditToolbarProp(lower(item));
    if ~isempty(propNames)
        return
    end
end
        
switch lower(item)
    case 'facecolor'
        if isprop(hObj,'FaceColorProperty')
            propNames = {get(hObj,'FaceColorProperty')};
            description = get(hObj,'FaceColorDescription');
        elseif isprop(hObj,'BackgroundColor')
            propNames = {'BackgroundColor'};
            description = getString(message('MATLAB:uistring:plotedittoolbar:BackgroundColor'));
        elseif ishghandle(hObj,'figure') ||  (ishghandle(hObj,'axes') && isprop(hObj,'Color'))
            propNames = {'Color'};
            description = getString(message('MATLAB:uistring:plotedittoolbar:Color'));
        end
    case 'edgecolor'                    
        if isprop(hObj,'EdgeColorProperty')
            propNames = {get(hObj,'EdgeColorProperty')};
            description = get(hObj,'EdgeColorDescription');
        elseif ishghandle(hObj,'line')
            propNames = {'Color'};
            description = getString(message('MATLAB:uistring:plotedittoolbar:Color'));
        elseif isprop(hObj,'EdgeColor')
            propNames = {'EdgeColor'};
            description = getString(message('MATLAB:uistring:plotedittoolbar:EdgeColor'));
        end
    case 'textcolor'
        if isprop(hObj,'TextColorProperty')
            propNames = {get(hObj,'TextColorProperty')};
            description = get(hObj,'TextColorDescription');
        elseif isprop(hObj,'TextColor')
            propNames = {'TextColor'};
            description = getString(message('MATLAB:uistring:plotedittoolbar:TextColor'));
        elseif ishghandle(hObj,'text')
            propNames = {'Color'};
            description = getString(message('MATLAB:uistring:plotedittoolbar:Color'));
        end
    case 'bold'
        if isprop(hObj,'FontWeight')
            propNames = {'FontWeight'};
            description = getString(message('MATLAB:uistring:plotedittoolbar:Bold'));
        end
    case 'italic'
        if isprop(hObj,'FontAngle')
            propNames = {'FontAngle'};
            description = getString(message('MATLAB:uistring:plotedittoolbar:Italic'));
        end
    case 'font'
        if isprop(hObj,'FontName')
            propNames = {'FontName'};
            description = getString(message('MATLAB:uistring:plotedittoolbar:Font'));
        end
    case {'rightalign','leftalign','centeralign'}
        if isprop(hObj,'HorizontalAlignment')
            propNames = {'HorizontalAlignment'};
            if strcmpi(item,'rightalign')
                description = getString(message('MATLAB:uistring:plotedittoolbar:AlignRight'));
            elseif strcmpi(item,'leftalign')
                description = getString(message('MATLAB:uistring:plotedittoolbar:AlignLeft'));
            else
                description = getString(message('MATLAB:uistring:plotedittoolbar:AlignCenter'));
            end
        end
end

%--------------------------------------------------------------%
function setToolbarItemProperties(hfig,item,prop,onoff)
switch lower(item)
    case 'facecolor'
        togg = findall(hfig,'tag','figToolScribeFaceColor');
    case 'edgecolor'
        togg = findall(hfig,'tag','figToolScribeEdgeColor');
    case 'textcolor'
        togg = findall(hfig,'tag','figToolScribeTextColor');
    case 'font'
        togg = findall(hfig,'tag','figToolScribeTextFont');
    case 'bold'
        togg = findall(hfig,'tag','figToolScribeTextBold');
    case 'italic'
        togg = findall(hfig,'tag','figToolScribeTextItalic');
    case 'leftalign'
        togg = findall(hfig,'tag','figToolScribeLeftTextAlign');
    case 'centeralign'
        togg = findall(hfig,'tag','figToolScribeCenterTextAlign');
    case 'rightalign'
        togg = findall(hfig,'tag','figToolScribeRightTextAlign');
    case 'all'
        Udata = getUdata(hfig);
        togg = Udata.handles;
end
% Only modify the state of toggletools which have changed until g646402 
% is fixed. Afterward, replace with set(togg,prop,onoff).
if ischar(prop)
    for j=1:length(togg)
        if ~strcmp(get(togg(j),prop),onoff)
            set(togg(j),prop,onoff);
        end
    end
elseif iscell(prop)
    for k=1:length(prop)
        for j=1:length(togg)
            if ~strcmp(get(togg(j),prop{k}),onoff{k})
                set(togg(j),prop{k},onoff{k});
            end
        end
    end
end
%--------------------------------------------------------------%
function setColortoggleCdata(hfig,item,color)

switch lower(item)
    case 'facecolor'
        togg = findall(hfig,'tag','figToolScribeFaceColor');
    case 'edgecolor'
        togg = findall(hfig,'tag','figToolScribeEdgeColor');
    case 'textcolor'
        togg = findall(hfig,'tag','figToolScribeTextColor');
    otherwise
        return;
end

% sets bottom 3 rows to new color
cdata = get(togg,'cdata');
emptycolor = cdata(1,1,:);
if ischar(color)
    for k=1:3
        cdata(15,:,k) = emptycolor(k);
    end
    cdata(14,:,:) = 0;
    cdata(16,:,:) = 0;
    cdata(15,1,:) = 0;
    cdata(15,16,:) = 0;
else
    for k=1:3
        cdata(14:16,:,k) = color(k);
    end
end
set(togg,'cdata',cdata);

%--------------------------------------------------------------%
function setToggleTooltip(hfig,item,tip)

switch item
    case 'facecolor'
        togg = findall(hfig,'tag','figToolScribeFaceColor');
    case 'edgecolor'
        togg = findall(hfig,'tag','figToolScribeEdgeColor');
    case 'textcolor'
        togg = findall(hfig,'tag','figToolScribeTextColor');
    otherwise
        return;
end

set(togg,'tooltip',tip);

%--------------------------------------------------------------%
function localProcessItem(obj,evd,hMode,item)

hFig = hMode.FigureHandle;

switch lower(item)
    case 'facecolor'
        hObjs = hMode.ModeStateData.SelectedObjects;
        [propNames, undoName] = localGetPropNames(hObjs(end),'FaceColor');
        graph2dhelper('scribeContextMenuCallback',obj,evd,'localExecuteColorCallback',hFig,propNames,undoName);
        set(obj,'State','off');
        for k=1:length(propNames)
            setColortoggleCdata(hFig,'FaceColor',get(hObjs(1),propNames{k}));
        end
    case 'edgecolor'
        hObjs = hMode.ModeStateData.SelectedObjects;
        [propNames, undoName] = localGetPropNames(hObjs(end),'EdgeColor');
        graph2dhelper('scribeContextMenuCallback',obj,evd,'localExecuteColorCallback',hFig,propNames,undoName);
        set(obj,'State','off');
        for k=1:length(propNames)
            setColortoggleCdata(hFig,'EdgeColor',get(hObjs(1),propNames{k}));
        end
    case 'textcolor'
        hObjs = hMode.ModeStateData.SelectedObjects;
        [propNames, undoName] = localGetPropNames(hObjs(end),'TextColor');
        graph2dhelper('scribeContextMenuCallback',obj,evd,'localExecuteColorCallback',hFig,propNames,undoName);
        set(obj,'State','off');
        for k=1:length(propNames)
            setColortoggleCdata(hFig,'TextColor',get(hObjs(1),propNames{k}));
        end
    case 'textfont'
        hObjs = hMode.ModeStateData.SelectedObjects;
        [~, undoName] = localGetPropNames(hObjs(end),'Font');
        graph2dhelper('scribeContextMenuCallback',obj,evd,'localExecuteFontCallback',hFig,undoName);
        set(obj,'State','off');
    case 'textbold'
        hObjs = hMode.ModeStateData.SelectedObjects;
        [propNames, undoName] = localGetPropNames(hObjs(end),'Bold');
        graph2dhelper('scribeContextMenuCallback',obj,evd,'localUpdateValue',hFig,propNames,'bold',undoName);
    case 'textnobold'
        hObjs = hMode.ModeStateData.SelectedObjects;
        propNames = '';
        undoName = '';
        if hMode.ModeStateData.IsHomogeneous
            [propNames, undoName] = localGetPropNames(hObjs(end),'Bold');
        end
        if ~all(cellfun('isempty',propNames))
            graph2dhelper('scribeContextMenuCallback',obj,evd,'localUpdateValue',hFig,propNames,'normal',undoName);
        end
    case 'textitalic'
        hObjs = hMode.ModeStateData.SelectedObjects;
        [propNames, undoName] = localGetPropNames(hObjs(end),'Italic');
        graph2dhelper('scribeContextMenuCallback',obj,evd,'localUpdateValue',hFig,propNames,'italic',undoName);
    case 'textnoitalic'
        hObjs = hMode.ModeStateData.SelectedObjects;
        propNames = {};
        undoName = '';
        if hMode.ModeStateData.IsHomogeneous
            [propNames, undoName] = localGetPropNames(hObjs(end),'Italic');
        end
        if ~all(cellfun('isempty',propNames))
            graph2dhelper('scribeContextMenuCallback',obj,evd,'localUpdateValue',hFig,propNames,'normal',undoName);
        end
    case 'textleft'
        hObjs = hMode.ModeStateData.SelectedObjects;
        [propNames, undoName] = localGetPropNames(hObjs(end),'LeftAlign');
        graph2dhelper('scribeContextMenuCallback',obj,evd,'localUpdateValue',hFig,propNames,'left',undoName);
        % Set the right and center buttons to the "off" position:
        setToolbarItemProperties(hFig,'centeralign','State','off');
        setToolbarItemProperties(hFig,'rightalign','State','off');
    case 'textcenter'
        hObjs = hMode.ModeStateData.SelectedObjects;
        [propNames, undoName] = localGetPropNames(hObjs(end),'CenterAlign');
        graph2dhelper('scribeContextMenuCallback',obj,evd,'localUpdateValue',hFig,propNames,'center',undoName);
        % Set the right and left buttons to the "off" position:
        setToolbarItemProperties(hFig,'leftalign','State','off');
        setToolbarItemProperties(hFig,'rightalign','State','off');
    case 'textright'
        hObjs = hMode.ModeStateData.SelectedObjects;
        [propNames, undoName] = localGetPropNames(hObjs(end),'RightAlign');
        graph2dhelper('scribeContextMenuCallback',obj,evd,'localUpdateValue',hFig,propNames,'right',undoName);
        % Set the left and center buttons to the "off" position:
        setToolbarItemProperties(hFig,'centeralign','State','off');
        setToolbarItemProperties(hFig,'leftalign','State','off');

end

%-------------------------------------------------------%
function Udata = getUdata(hfig)

uddfig = handle(hfig);

if isprop(uddfig,'PlotEditToolbarHandles')
    Udata = uddfig.PlotEditToolbarHandles;
else
    Udata = [];
end

%--------------------------------------------------------------%
function setUdata(hfig,Udata)

uddfig = handle(hfig);
if ~isprop(uddfig,'PlotEditToolbarHandles')
    if ~isobject(uddfig)
        hprop = schema.prop(uddfig,'PlotEditToolbarHandles','MATLAB array');
        hprop.AccessFlags.Serialize = 'off';
        hprop.Visible = 'off';
    else
        hprop = addprop(hfig,'PlotEditToolbarHandles');
        hprop.Transient = true;
        hprop.Hidden = true;
    end
end
uddfig.PlotEditToolbarHandles = Udata;


%--------------------------------------------------------------%
function initUdata(hfig)

Udata = getUdata(hfig);
setUdata(hfig,Udata);

function cdata = loadicon(filename)

% Load cdata from *.png file
if length(filename)>3 && strncmp(filename(end-3:end),'.png',4)
    [cdata, ~, alpha] = imread(filename,'Background','none');
    % Converting 16-bit integer colors to MATLAB colorspec
    cdata = double(cdata) / 65535.0;
    % Set all transparent pixels to be transparent (nan)
    cdata(alpha==0) = NaN;
else
    cdata = NaN;
end
