function entry = createScribeUIMenuEntry(hParent,menuType,displayText,propName,undoName,varargin)
% Create a scribe entry for a UIContextMenu
% hFig - The parent to operate on. either a figure of a uicontextmenu
% menuType - String representing the
%            expected result of calling the menu.
% displayText - The text to be displayed in the menu.
% propName - The name of the property being modified.
% undoName - The string to be shown in the undo menu

%   Copyright 2006-2015 The MathWorks, Inc.

switch menuType
    case 'CapSize'
        entry = localCreateCapSizeEntry(hParent,displayText,propName,undoName);
    case 'Color'
        entry = localCreateColorEntry(hParent,displayText,propName,undoName);
    case 'LineWidth'
        entry = localCreateLineWidthEntry(hParent,displayText,propName,undoName);
    case 'LineStyle'
        entry = localCreateLineStyleEntry(hParent,displayText,propName,undoName);
    case 'HeadStyle'
        entry = localCreateHeadStyleEntry(hParent,displayText,propName,undoName);
    case 'HeadSize'
        entry = localCreateHeadSizeEntry(hParent,displayText,propName,undoName);
    case 'AddData'
        entry = localCreateAddDataEntry(hParent,displayText);
    case 'LegendToggle'
        entry = localCreateLegendToggleEntry(hParent,displayText);
    case 'Toggle'
        entry = localCreateToggleEntry(hParent,displayText,propName,undoName);
    case 'Marker'
        entry = localCreateMarkerEntry(hParent,displayText,propName,undoName);
    case 'MarkerSize'
        entry = localCreateMarkerSizeEntry(hParent,displayText,propName,undoName);
    case 'EditText'
        entry = localCreateEditTextEntry(hParent,displayText);
    case 'Font'
        entry = localCreateFontEntry(hParent,displayText,propName,undoName);
    case 'TextInterpreter'
        entry = localCreateTextInterpreterEntry(hParent,displayText,propName,undoName);
    case 'CloseFigure'
        entry = localCreateCloseFigureEntry(hParent,displayText);
    case 'BarWidth'
        entry = localCreateBarWidthEntry(hParent,displayText,propName,undoName);
    case 'BarLayout'
        entry = localCreateBarLayoutEntry(hParent,displayText,propName,undoName);
    case 'AutoScaleFactor'
        entry = localCreateAutoScaleFactorEntry(hParent,displayText,propName,undoName);
    case 'EnumEntry'
        entry = localCreateEnumEntry(hParent,displayText,propName,varargin{:},undoName);
    case 'CustomEnumEntry'
        entry = localCreateCustomEnumEntry(hParent,displayText,propName,varargin{:});        
    case 'GeneralAction'
        entry = localCreateActionEntry(hParent,displayText,varargin{:});
    case 'DisplayStyle'
        entry = localCreateDisplayStyleEntry(hParent,displayText,propName,undoName);
    case 'DisplayStyle2D'
        entry = localCreateDisplayStyle2DEntry(hParent,displayText,propName,undoName);   
    case 'morebins'
        entry = localCreateMoreFewerbinsEntry(hParent,displayText,propName,undoName);
    case 'fewerbins'
        entry = localCreateMoreFewerbinsEntry(hParent,displayText,propName,undoName);
    case 'morebins2D'
        entry = localCreateMoreFewerbins2DEntry(hParent,displayText,propName);
    case 'fewerbins2D'
        entry = localCreateMoreFewerbins2DEntry(hParent,displayText,propName);
    case 'DisplayOrder'
        entry = localCreateDisplayOrderEntry(hParent,displayText,propName);
    case 'AlignBins'
        entry = localCreateAlignBinsEntry(hParent,displayText,undoName);
end

%----------------------------------------------------------------------%
function entry = localCreateActionEntry(hParent,displayText,callbackFunction)

entry = uimenu(hParent,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',callbackFunction);

%----------------------------------------------------------------------%
function entry = localCreateAutoScaleFactorEntry(hParent,displayText,propName,undoName)
% Create a uimenu that brings up a list of scale sizes

values = [.2,.3,.4,.5,.7,.9,1.0];
format = '%1.1f';

entry = localCreateNumEntry(hParent,displayText,propName,values,format,undoName);

%----------------------------------------------------------------------%
function entry = localCreateBarWidthEntry(hParent,displayText,propName,undoName)
% Create a uimenu that brings up a list of bar width sizes

values = [.2,.3,.4,.5,.6,.7,.8,.9,1.0];
format = '%1.1f';

entry = localCreateNumEntry(hParent,displayText,propName,values,format,undoName);

%----------------------------------------------------------------------%
function entry = localCreateBarLayoutEntry(hParent,displayText,propName,undoName)
% Create a uimenu that is linked to text interpreters

descriptions = {getString(message('MATLAB:uistring:scribemenu:Grouped')),getString(message('MATLAB:uistring:scribemenu:Stacked'))};
values = {'grouped','stacked'};

entry = localCreateEnumEntry(hParent,displayText,propName,descriptions,values, undoName);

%----------------------------------------------------------------------%
function entry = localCreateCloseFigureEntry(hParent,displayText)
% Create a uimenu that closes the figure

entry = uimenu(hParent,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',{@localCloseFigure,hParent});

%----------------------------------------------------------------------%
function localCloseFigure(~,~,hParent) 
% Close the figure

close(localGetFigure(hParent));

%----------------------------------------------------------------------%
function entry = localCreateTextInterpreterEntry(hParent,displayText,propName,undoName)
% Create a uimenu that is linked to text interpreters

descriptions = cellfun(@(x)getString(message(['MATLAB:uistring:scribemenu:' x ])),{'latex','tex','none'},'UniformOutput',false);
values = {'latex','tex','none'};

entry = localCreateEnumEntry(hParent,displayText,propName,descriptions,values, undoName);

%----------------------------------------------------------------------%
function entry = localCreateFontEntry(hParent,displayText,propName,undoName) %#ok<INUSL>
% Create a uimenu that brings up a font picker.

entry = uimenu(hParent,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',{@localScribeContextMenuCallback,'localExecuteFontCallback',hParent,undoName});

%----------------------------------------------------------------------%
function entry = localCreateEditTextEntry(hParent,displayText)
% Create a uimenu that sets text into edit mode

entry = uimenu(hParent,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',{@localEditText,hParent});

%----------------------------------------------------------------------%
function localEditText(~,~,hParent)
% Get a handle to the mode. Though this creates an interdependency, it is
% mitigated by the guarantee that this callback is only executed while the
% mode is active, and thus already created.

hFig = localGetFigure(hParent);
if isactiveuimode(hFig,'Standard.EditPlot')
    hPlotEdit = plotedit(hFig,'getmode');
    hMode = hPlotEdit.ModeStateData.PlotSelectMode;
    hObj = hMode.ModeStateData.SelectedObjects;
else
    hObj = hittest(hFig);
end

set(hObj,'Editing','on');

%----------------------------------------------------------------------%
function entry = localCreateMarkerSizeEntry(hParent,displayText,propName,undoName)
% Create a uimenu that brings up a list of marker sizes

values = [2,4,5,6,7,8,10,12,18,24,48];
format = '%1.0f';

entry = localCreateNumEntry(hParent,displayText,propName,values,format,undoName);

%----------------------------------------------------------------------%
function entry = localCreateHeadSizeEntry(hParent,displayText,propName,undoName)
% Create a uimenu that brings up a list of marker sizes

values = [6,8,10,12,15,20,25,30,40];
format = '%2.0f';

entry = localCreateNumEntry(hParent,displayText,propName,values,format,undoName);

%----------------------------------------------------------------------%
function entry = localCreateCapSizeEntry(hParent,displayText,propName,undoName)
% Create a uimenu that brings up a list of cap sizes

values = [6,9,12,15,18,24,30,36,48,60,72];
format = '%1.0f';

entry = localCreateNumEntry(hParent,displayText,propName,values,format,undoName);

%----------------------------------------------------------------------%
function entry = localCreateMarkerEntry(hParent,displayText,propName,undoName)
% Creates a uimenu that represents marker types

descriptions = {'+','o','*','.','x',getString(message('MATLAB:uistring:scribemenu:square')),getString(message('MATLAB:uistring:scribemenu:diamond')),'v','^','>','<',getString(message('MATLAB:uistring:scribemenu:pentagram')),getString(message('MATLAB:uistring:scribemenu:hexagram')),getString(message('MATLAB:uistring:scribemenu:none'))};
values = {'+','o','*','.','x','square','diamond','v','^','>','<','pentagram','hexagram','none'};

entry = localCreateEnumEntry(hParent,displayText,propName,descriptions,values, undoName);


%----------------------------------------------------------------------%
function entry = localCreateToggleEntry(hParent,displayText,propName,undoName)
% Creates a uimenu that sets a property to "on" or "off" 

entry = uimenu(hParent,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',{@localToggleValue,hParent,propName,undoName});

%----------------------------------------------------------------------%
function localToggleValue(obj,evd,hParent,propName,undoName)
% Sets the toggle value

% The value to set is the "Checked" property 
if strcmpi(get(obj,'Checked'),'on')
    checkValue = 'off';
else
    checkValue = 'on';
end

scribeContextMenuCallback(obj,evd,'localUpdateValue',localGetFigure(hParent),propName,checkValue,undoName);

%----------------------------------------------------------------------%
function entry = localCreateLegendToggleEntry(hParent,displayText)
% Create a uimenu entry that toggles a legend.

entry = uimenu(hParent,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',{@localToggleLegend,hParent});

%----------------------------------------------------------------------%
function localToggleLegend(~,~,hParent)
% Get a handle to the mode. Though this creates an interdependency, it is
% mitigated by the guarantee that this callback is only executed while the
% mode is active, and thus already created.
hFig = localGetFigure(hParent);
if isactiveuimode(hFig,'Standard.EditPlot')
    hPlotEdit = plotedit(hFig,'getmode');
    hMode = hPlotEdit.ModeStateData.PlotSelectMode;
    hObj = hMode.ModeStateData.SelectedObjects;
else
    hObj = hittest(hFig);
end

for i=1:length(hObj)
    legend(double(hObj(i)),'Toggle');
end

%----------------------------------------------------------------------%
function entry = localCreateAddDataEntry(hParent,displayText)
% Create the menu entry which adds data to an axes.

entry = uimenu(hParent,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',{@localAddData,hParent});

%----------------------------------------------------------------------%
function localAddData(~,~,hParent)
% Get a handle to the mode. Though this creates an interdependency, it is
% mitigated by the guarantee that this callback is only executed while the
% mode is active, and thus already created.
hFig = localGetFigure(hParent);
if isactiveuimode(hFig,'Standard.EditPlot')
    hPlotEdit = plotedit(hFig,'getmode');
    hMode = hPlotEdit.ModeStateData.PlotSelectMode;
    hObj = hMode.ModeStateData.SelectedObjects;
else
    hObj = hittest(hFig);
end

adddatadlg(hObj, hFig);

%----------------------------------------------------------------------%
function entry = localCreateLineStyleEntry(hParent,displayText,propName,undoName)
% Create a uimenu that brings up a list of line styles

descriptions = cellfun(@(x)getString(message(['MATLAB:uistring:scribemenu:' x ])),{'solid','dash','dot','dash_dot','none'},'UniformOutput',false);
values = {'-','--',':','-.','none'};

entry = localCreateEnumEntry(hParent,displayText,propName,descriptions,values,undoName);

%----------------------------------------------------------------------%
function entry = localCreateHeadStyleEntry(hParent,displayText,propName,undoName)
% Create a uimenu that brings up a list of line styles

descriptions = cellfun(@(x)getString(message(['MATLAB:uistring:scribemenu:' x ])),{'None_2','Plain','V_Back','C_Back','Diamond_2','Deltoid'},'UniformOutput',false);
values = {'none','plain','vback2','cback2','diamond','deltoid'};

entry = localCreateEnumEntry(hParent,displayText,propName,descriptions,values,undoName);

%----------------------------------------------------------------------%
function entry = localCreateEnumEntry(hParent,displayText,propName,descriptions,values,undoName)
% General helper function for enumerated types

entry = uimenu(hParent,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',{@localUpdateEnumCheck,hParent,propName,descriptions,values});
for k=1:length(values)
    uimenu(entry,...
        'HandleVisibility','off',...
        'Label',descriptions{k},...
        'Separator','off',...
        'Visible','off',...
        'Tag', [propName '.Item' num2str(k)], ...
        'Callback',{@localScribeContextMenuCallback,'localUpdateValue',hParent,propName,values{k},undoName});
end

%----------------------------------------------------------------------%
function entry = localCreateCustomEnumEntry(hParent,displayText,propName,descriptions,values,callback)
% General helper function for enumerated types

if ~iscell(callback)
    callback = {callback};
end

entry = uimenu(hParent,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',{@localUpdateEnumCheck,hParent,propName,descriptions,values});
for k=1:length(values)
    uimenu(entry,...
        'HandleVisibility','off',...
        'Label',descriptions{k},...
        'Separator','off',...
        'Visible','off',...
        'Tag', [propName '.Item' num2str(k)], ...
        'Callback',[callback,{hParent,values{k}}]);
end

%----------------------------------------------------------------------%
function localUpdateEnumCheck(obj,evd,hParent,propName,descriptions,values) %#ok<INUSL>
% For uimenu entries with children, make sure the proper one is checked

% Get a handle to the mode. Though this creates an interdependency, it is
% mitigated by the guarantee that this callback is only executed while the
% mode is active, and thus already created.

hFig = localGetFigure(hParent);
if isactiveuimode(hFig,'Standard.EditPlot')
    hPlotEdit = plotedit(hFig,'getmode');
    hMode = hPlotEdit.ModeStateData.PlotSelectMode;
    hObjs = hMode.ModeStateData.SelectedObjects;
else
    hMenu = ancestor(obj,'UIContextMenu');
    if isappdata(hMenu,'CallbackObject')
        hObjs = getappdata(hMenu,'CallbackObject');
    else
        hObjs = hittest(hFig);
    end
end
value = get(hObjs(end),propName);
location = strcmpi(value,values);
if any(location)
    label = descriptions{strcmpi(value,values)};
    menus = findall(obj,'Label',label);
    hPar = get(menus(1),'Parent');
else
    menus = [];
    hTemp = findall(obj,'Label',descriptions{1});
    hPar = get(hTemp(1),'Parent');
end
hSibs = findall(hPar);
set(hSibs(2:end),'Checked','off');
set(menus,'Checked','on');

%----------------------------------------------------------------------%
function entry = localCreateLineWidthEntry(hParent,displayText,propName,undoName)
% Create a uimenu that brings up a list of line widths

values = [.5,1:1:12];
format = '%1.1f';

entry = localCreateNumEntry(hParent,displayText,propName,values,format,undoName);

%----------------------------------------------------------------------%
function entry = localCreateNumEntry(hParent,displayText,propName,values,format,undoName)
% General helper function for menus with numeric values.
entry=uimenu(hParent,...
         'HandleVisibility','off',...
         'Label',displayText,...
         'Visible','off',...
         'Callback',{@localUpdateCheck,hParent,propName,format});     
for k=1:length(values)
  uimenu(entry,...
         'HandleVisibility','off',...
         'Label',sprintf(format,values(k)),...
         'Separator','off',...
         'Visible','off',...
         'Tag', [propName '.Item' num2str(k)], ...
         'Callback',{@localScribeContextMenuCallback,'localUpdateValue',hParent,propName,values(k),undoName});
     
     
end

%----------------------------------------------------------------------%
function localUpdateCheck(obj,evd,hParent,propName,format) %#ok<INUSL>
% For uimenu entries with children, make sure the proper one is checked

% Get a handle to the mode. Though this creates an interdependency, it is
% mitigated by the guarantee that this callback is only executed while the
% mode is active, and thus already created.)
hFig = localGetFigure(hParent);
if isactiveuimode(hFig,'Standard.EditPlot')
    hPlotEdit = plotedit(hFig,'getmode');
    hMode = hPlotEdit.ModeStateData.PlotSelectMode;
    hObjs = hMode.ModeStateData.SelectedObjects;
else
    hMenu = ancestor(obj,'UIContextMenu');
    if isappdata(hMenu,'CallbackObject')
        hObjs = getappdata(hMenu,'CallbackObject');
    else
        hObjs = hittest(hFig);
    end
end

if ~isprop(hObjs(end),propName)
    return;
end

value = get(hObjs(end),propName);
label = sprintf(format,value);
menus = findall(obj,'Label',label);
if ~isempty(menus)
    hPar = get(menus(1),'Parent');
else
    menus = [];
    hPar = obj;
end
hSibs = findall(hPar);
set(hSibs(2:end),'Checked','off');
set(menus,'Checked','on');

%----------------------------------------------------------------------%
function entry = localCreateColorEntry(hParent,displayText,propName,undoName)
% Create a uimenu that brings up a color dialog:

entry = uimenu(hParent,'HandleVisibility','off','Label',displayText, ...
    'Callback',{@localScribeContextMenuCallback,'localExecuteColorCallback',hParent,propName,undoName});

%----------------------------------------------------------------------%
function hFig = localGetFigure(hParent)

if ishghandle(hParent,'figure')
    hFig = hParent;
elseif ishghandle(hParent,'uicontextmenu')
    hFig = get(hParent,'Parent');
else
    hFig = ancestor(hParent,'figure');
end

%----------------------------------------------------------------------%

function localScribeContextMenuCallback(es,ed,switchArg,hParent,varargin)

scribeContextMenuCallback(es,ed,switchArg,localGetFigure(hParent),varargin{:});

%----------------------------------------------------------------------%
function entry = localCreateDisplayStyleEntry(hParent,displayText,propName,undoName)
% Create a uimenu that brings up a list of histogram display styles

values = {'bar','stairs'};
descriptions = cellfun(@(x)getString(message(['MATLAB:uistring:scribemenu:' x ])),values,'UniformOutput',false);

entry = localCreateEnumEntry(hParent,displayText,propName,descriptions,values, undoName);

%----------------------------------------------------------------------%
function entry = localCreateDisplayStyle2DEntry(hParent,displayText,propName,undoName)
% Create a uimenu that brings up a list of histogram2 display styles

values = {'bar3','tile'};
descriptions = cellfun(@(x)getString(message(['MATLAB:uistring:scribemenu:' x ])),values,'UniformOutput',false);

entry = localCreateEnumEntry(hParent,displayText,propName,descriptions,values, undoName);

%----------------------------------------------------------------------%
function entry = localCreateMoreFewerbinsEntry(hParent,displayText,methodName,undoName)
% creates a uimenu that increments the number of histogram bins

entry = uimenu(hParent,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',{@localScribeContextMenuCallback,'localMoreFewerBinsCallback',...
                hParent, str2func(methodName), undoName});

 %----------------------------------------------------------------------%
function entry = localCreateMoreFewerbins2DEntry(hParent,displayText,methodName)
% creates a uimenu that increments the number of 2D histogram bins

entry = uimenu(hParent,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off');
uimenu(entry, ...
    'HandleVisibility','off',...
    'Label',getString(message('MATLAB:uistring:scribemenu:XAxisOnly')),...
    'Visible','off',...
    'Callback',{@localScribeContextMenuCallback,'localMoreFewerBins2DCallback',...
    hParent, str2func(methodName), 'x', ...
    getString(message(['MATLAB:uistring:scribemenu:' methodName 'x']))});
uimenu(entry, ...
    'HandleVisibility','off',...
    'Label',getString(message('MATLAB:uistring:scribemenu:YAxisOnly')),...
    'Visible','off',...
    'Callback',{@localScribeContextMenuCallback,'localMoreFewerBins2DCallback',...
                hParent, str2func(methodName), 'y', ...
                getString(message(['MATLAB:uistring:scribemenu:' methodName 'y']))});
uimenu(entry, ...
    'HandleVisibility','off',...
    'Label',getString(message('MATLAB:uistring:scribemenu:XAndYAxes')),...
    'Visible','off',...
    'Callback',{@localScribeContextMenuCallback,'localMoreFewerBins2DCallback',...
                hParent, str2func(methodName), 'both', ...
                getString(message(['MATLAB:uistring:scribemenu:' methodName 'xy']))});        
            
%----------------------------------------------------------------------%
function entry = localCreateDisplayOrderEntry(hParent,displayText,propName)
% creates a uimenu that changes the order of axes children

entry = uimenu(hParent,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off');
uimenu(entry,...
    'HandleVisibility','off',...
    'Label',getString(message('MATLAB:uistring:scribemenu:BringToFront')),...
    'Visible','off',...
    'Tag', [propName '.BringToFront'], ...
    'Callback',{@localScribeContextMenuCallback,'localDisplayOrderCallback',...
                hParent, inf, getString(message('MATLAB:uistring:scribemenu:BringToFront'))});  
uimenu(entry,...
    'HandleVisibility','off',...
    'Label',getString(message('MATLAB:uistring:scribemenu:SendToBack')),...
    'Visible','off',...
    'Tag', [propName '.SendToBack'], ...    
    'Callback',{@localScribeContextMenuCallback,'localDisplayOrderCallback',...
                hParent, -inf, getString(message('MATLAB:uistring:scribemenu:SendToBack'))});     
uimenu(entry,...
    'HandleVisibility','off',...
    'Label',getString(message('MATLAB:uistring:scribemenu:BringForward')),...
    'Visible','off',...
    'Tag', [propName '.BringForward'], ...      
    'Callback',{@localScribeContextMenuCallback,'localDisplayOrderCallback',...
                hParent, 1, getString(message('MATLAB:uistring:scribemenu:BringForward'))});  
uimenu(entry,...
    'HandleVisibility','off',...
    'Label',getString(message('MATLAB:uistring:scribemenu:SendBackward')),...
    'Visible','off',...
    'Tag', [propName '.SendBackward'], ...   
    'Callback',{@localScribeContextMenuCallback,'localDisplayOrderCallback',...
                hParent, -1, getString(message('MATLAB:uistring:scribemenu:SendBackward'))});             
%----------------------------------------------------------------------%
 function entry = localCreateAlignBinsEntry(hParent,displayText,undoName)
% Create a uimenu that align bins of multiple histograms

entry = uimenu(hParent,...
    'HandleVisibility','off',...
    'Label',displayText,...
    'Visible','off',...
    'Callback',{@localScribeContextMenuCallback,'localAlignBinsCallback',...
                hParent, undoName});

    
            
