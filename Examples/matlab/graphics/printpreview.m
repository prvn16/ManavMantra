function varargout = printpreview(varargin)
%PRINTPREVIEW  Display preview of figure to be printed
%    PRINTPREVIEW(FIG) Display preview of FIG

%   Copyright 1984-2017 The MathWorks, Inc.

% Generate a warning in -nodisplay and -noFigureWindows mode.
warnfiguredialog('printpreview');

narginchk(0,1);

%Get the fig whose preview is requested
if nargin==1
  fig = varargin{1};
  if isempty(fig) || ~isscalar(fig) || ~ishghandle(fig) 
    error(message('MATLAB:printpreview:InvalidFigureHandle'));
  end
else
  fig = gcf;
end

matlab.ui.internal.UnsupportedInUifigure(fig);

% Call the old print preview if needed.
if useOriginalHGPrinting(fig)
    previewFigure = oldPrintPreview(fig);
    if nargout==1
        varargout{1} = previewFigure;
    end
    return;
end

nargoutchk(0,0);

%Create a figure for preview
figPreview = matlab.graphics.internal.createPrintPreviewFigure();

% If normalized units, change over to default PaperUnits
if strcmpi(fig.PaperUnits, 'normalized')
    defaultPU = get(groot, 'DefaultFigurePaperUnits');
    if strcmpi(defaultPU, 'normalized') % If default units are setup to be normalized, use inches. 
        defaultPU = 'inches';        
    end
    set(fig, 'PaperUnits', defaultPU);
    warning(message('MATLAB:printpreview:NormalizedPaperUnitsNotSupported', defaultPU))
end

%Init the preview region
axPreview = createPreviewRegion(handle(figPreview),fig);

% First, get the props
props = ppgetprinttemplate(fig);
setappdata(axPreview, 'PrintProperties', props);
setPrintProps(axPreview, fig);
updateImage(axPreview, fig, true);
showHeaderAndDate(axPreview, fig);

% Set windowbutton and resize functions on the preview figure
set(figPreview,'ResizeFcn',{@onResize, fig, axPreview})
toggleInteractiveRulers(figPreview, axPreview, fig)

%Set the position of the figure
pos = str2num(com.mathworks.page.export.PrintExportSettings.getFigPos);  %#ok
if isempty(pos)   
    pos = get(figPreview, 'Position');
    originalRootUnits = get(groot, 'Units');
    set(groot, 'Units', 'pixels');
    screen = get(groot,'ScreenSize');
    set(groot, 'Units', originalRootUnits);
    pos(2) = screen(4)/8.0;
    pos(4) = 3*screen(4)/4.0;
end
set(figPreview, 'Position', pos);

setappdata(fig, 'PrintPreview', figPreview);

set(figPreview, 'DeleteFcn', @onFigPreviewClosing);

% Set the figPreview to be visible 
set(figPreview, 'Visible', 'on');
drawnow; 

% Setup the Print Export Panel
createPrintExportPanel(figPreview, axPreview, fig, props)
drawnow;
onResize([], [], fig, axPreview)
drawnow;

% Setup timer to auto refresh any updates received from Java
tim = timer('TimerFcn',{@onRefresh,axPreview,fig}, 'Period', .2,...
    'ExecutionMode','FixedRate');
setappdata(figPreview,'Timer',tim);
start(tim);

% Block MATLAB execution
uiwait(figPreview);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function createPrintExportPanel(figPreview, axPreview, fig, props)

%Snap the properties panel to the left
dir = [prefdir '/PrintSetup'];
if ~exist(dir,'dir')
    mkdir(dir);
end
panel = javaObjectEDT('com.mathworks.page.export.PrintExportPanel', dir);

javacomponent(panel, java.awt.BorderLayout.WEST, figPreview);

model = panel.getPrintExportSettings();
setappdata(figPreview,'JavaModel',model);

p = javaObjectEDT('com.mathworks.page.export.PreviewTabLayout', model);
panel.addTabbedPanel(getString(message('MATLAB:uistring:printpreview:LayoutTab')),'Layout', p);

p = javaObjectEDT('com.mathworks.page.export.PreviewTabLines', model, listfonts, get(fig,'DefaultTextFontName'));
panel.addTabbedPanel(getString(message('MATLAB:uistring:printpreview:LinesTextTab')),'Lines/Text', p);

p = javaObjectEDT('com.mathworks.page.export.PreviewTabColor', model);
panel.addTabbedPanel(getString(message('MATLAB:uistring:printpreview:ColorTab')),'Color', p); 

p = javaObjectEDT('com.mathworks.page.export.PreviewTabMisc', model);
panel.addTabbedPanel(getString(message('MATLAB:uistring:printpreview:AdvancedTab')),'Advanced', p);

panel.setActiveTab(0);

% Initialize the model
panel.initialize(-1, -1, fieldnames(props), struct2cell(props));

%Setup the callback to the (Java) PrintExportPanel
callback = handle(model.getCallback(), 'callbackProperties');
set(callback, 'delayedCallback', {@onJavaCallback, fig, axPreview});
setappdata(figPreview,'JavaCallback',callback);
setappdata(figPreview,'JavaPanel',panel);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onFigPreviewClosing(figPreview, ~) 
if ~ishghandle(figPreview)
	return;
end
if isappdata(figPreview, 'Timer')
	t = getappdata(figPreview, 'Timer');
	if ~isempty(t)
	    stop(t);
	    delete(t);
	end
end
delete(figPreview);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function toggleInteractiveRulers(figPreview, axPreview, fig)
% Enables/disables the rulers & interactively changing the PaperPosition. 
axRulerVer = getappdata(axPreview, 'RulerVertical');
axRulerHor = getappdata(axPreview, 'RulerHorizontal');
if strcmpi(get(fig,'PaperPositionMode'),'manual')
    set(figPreview,'WindowButtonDownFcn',{@wbdown, axPreview}, ...
        'WindowButtonUpFcn',{@wbup, fig, getappdata(figPreview,'JavaModel'), axPreview}, ...
        'WindowButtonMotionFcn',{@wbmotion, fig, axPreview});
    set(axRulerVer, 'Color','w');
    set(axRulerHor, 'Color','w');
else % if 'auto'
    set(figPreview,'WindowButtonDownFcn','', ...
        'WindowButtonUpFcn','', ...
        'WindowButtonMotionFcn','');
    % Change the color of the rulers to gray.
    set(axRulerVer, 'Color',[.8 .8 .8]);
    set(axRulerHor, 'Color',[.8 .8 .8]);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function axPreview = createPreviewRegion(figPreview,fig)

col = get(fig, 'DefaultUicontrolBackgroundColor');
set(figPreview,'Color', col);

jpanelBtns = javaObjectEDT('com.mathworks.page.export.PreviewZoomPanel');
[jpanelBtns, pnlButtons] = javacomponent(jpanelBtns, [], handle(figPreview));
set(pnlButtons,'Tag','PanelPreviewButtons');
setappdata(figPreview,'JavaButtons',jpanelBtns);

pnlPreviewAxes = uicontainer('Parent',figPreview,'Tag','PanelPreviewAxes',...
                  'units','pixels','BackgroundColor',col);

% The various axes (PreviewAxes, Rulers)
axPreview = axes('Parent',pnlPreviewAxes,'Box','on',...
                 'Units', 'pixels',...
                 'XLim', [0 1], 'YLim', [0 1],...
                 'XTick',[],'YTick',[],...
                 'XLimMode','manual','YLimMode','manual','ZLimMode','manual',...
                 'Layer','bottom',...
                 'NextPlot','add',...
                 'ButtonDownFcn','',...
                 'Tag','PreviewAxes', ...
                 'ALimMode','manual','CLimMode','manual');
axRulerHor = axes('Parent',figPreview,'HandleVisibility','off',...
                  'Box','on','Units', 'pixels','Layer','top',...
                  'XGrid','on','GridLineStyle','-',... 
                  'XAxisLocation','top',...
                  'XLim', [0 1], 'YLim', [0 1],...
                  'YTick', [], 'Color','w','TickLength',[0 0], ...
                  'XLimMode','manual','YLimMode','manual','ZLimMode','manual',...
                  'NextPlot','add',...
                  'ButtonDownFcn','',...
                  'Tag','PreviewRulerHorizontal', ...
                  'ALimMode','manual','CLimMode','manual');
axRulerVer = axes('Parent',figPreview,'HandleVisibility','off',...
                  'Box','on','Units', 'pixels','Layer','top',...
                  'XLim', [0 1], 'YLim', [0 1],'YDir','reverse',...
                  'YGrid','on','GridLineStyle','-',...
                  'XTick',[],'Color','w','TickLength',[0 0],...
                  'XLimMode','manual','YLimMode','manual','ZLimMode','manual',...
                  'NextPlot','add',...
                  'ButtonDownFcn','',...
                  'Tag','PreviewRulerVertical', ...
                  'ALimMode','manual','CLimMode','manual');
dark = col*.9;  %#ok
makeMarker(axRulerVer,'Top',col,'top');
makeMarker(axRulerVer,'Bottom',col,'bottom');
makeMarker(axRulerVer,'MiddleVer',col,'top');
makeMarker(axRulerHor,'Right',col,'right');
makeMarker(axRulerHor,'Left',col,'left');
makeMarker(axRulerHor,'MiddleHor',col,'right');

setappdata(axPreview, 'RulerHorizontal', axRulerHor);
setappdata(axPreview, 'RulerVertical', axRulerVer);

% the overlay axes with repaint busy message
overlay = axes('Parent',pnlPreviewAxes,'Box','off','Visible','off',...
               'Position',[0 0 1 1],'XLim',[0 1],'YLim',[0 1]);
text(.3,.5,getString(message('MATLAB:uistring:printpreview:RecomputingPreview')),'Units','normalized',...
     'HorizontalAlignment','left','VerticalAlignment','middle',...
     'Parent',overlay,'Visible','off','Tag','BusyMessage',...
     'Interpreter','none');
setappdata(figPreview,'Overlay',overlay)

% The image for the printed figure
image([0 1],[0 1],[], 'Parent',axPreview, 'Visible', 'on');         

% Imaginary line in the previewAxes representing the margin (that is being
% moved interactively)
line('Parent',axPreview,'Visible','off','HandleVisibility','off',...
     'LineStyle',':','Tag','PreviewMargin');

% scrollbars
panx = uicontrol('Parent', figPreview, 'Style', 'slider', ...
                 'Tag', 'PreviewPanx', 'Value', 0.5);
pany = uicontrol('Parent', figPreview, 'Style', 'slider', ...
                 'Tag', 'PreviewPany', 'Value', 0.5);

addlistener(panx, 'ContinuousValueChange', @(src, evt) onScroll(src, evt, axPreview, fig));
addlistener(pany, 'ContinuousValueChange', @(src, evt) onScroll(src, evt, axPreview, fig));

% The text fields representing the header, and the date
text('Parent',axPreview, 'VerticalAlignment', 'top', ...
     'HorizontalAlignment', 'left', 'Clipping', 'on', 'Tag', 'PreviewHeader');
text('Parent',axPreview, 'VerticalAlignment', 'top', ...
     'HorizontalAlignment', 'right', 'Clipping', 'on', 'Tag', 'PreviewDate');
     
% The Print, refresh, close, zoom controls
btn = jpanelBtns.getPrintButton();
h1 = handle(btn,'callbackproperties');
set(h1,'ActionPerformedCallback',{@onPrint,fig});
btn = jpanelBtns.getRefreshButton();
h2 = handle(btn,'callbackproperties');
set(h2,'ActionPerformedCallback',{@onRefresh,axPreview,fig});
btn = jpanelBtns.getCloseButton();
h3 = handle(btn,'callbackproperties');
set(h3,'ActionPerformedCallback',{@onClose,figPreview});
btn = jpanelBtns.getZoomComboBox();
h4 = handle(btn,'callbackproperties');
set(h4,'ActionPerformedCallback',{@onPaperZoom,axPreview,fig});
btn = jpanelBtns.getHelpButton();
h5 = handle(btn,'callbackproperties');
set(h5,'ActionPerformedCallback',@onHelp);
setappdata(figPreview,'Buttons',[h1 h2 h3 h4 h5]);
drawnow;
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function resizeDialog(axPreview, fig)
figPreview = ancestor(axPreview, 'figure');
figPos = get(figPreview,'Position'); % in pixels
rulerWidth = 40; %pixels 
scrollWidth = 15;
btnHeight = 30;
border = 10;

% Set the positions of the various panels and the scrollbars
pnlPreview = findobj(figPreview,'Tag','PanelPreviewAxes');
pnlButtons = findobj(figPreview,'Tag','PanelPreviewButtons');
set(pnlButtons, 'Position', [1 figPos(4)-btnHeight figPos(3) btnHeight]);
panx = findobj(figPreview, 'Type', 'uicontrol', 'Tag', 'PreviewPanx');
pany = findobj(figPreview, 'Type', 'uicontrol', 'Tag', 'PreviewPany');
panpos = [1 1 figPos(3)-scrollWidth scrollWidth];
panpos(3:4) = max(panpos(3:4),[1 1]);
set(panx, 'Position', panpos);
panpos = [figPos(3)-scrollWidth scrollWidth scrollWidth figPos(4)-scrollWidth-btnHeight];
panpos(3:4) = max(panpos(3:4),[1 1]);
set(pany, 'Position', panpos);
pos = [1 scrollWidth ...
       figPos(3)-scrollWidth ...
       figPos(4)-scrollWidth-btnHeight];
pnlpos = [pos(1)+rulerWidth+border pos(2)+border ...
          pos(3)-rulerWidth-2*border pos(4)-rulerWidth-2*border];
pnlpos(3:4) = max(pnlpos(3:4), [1 1]);
set(pnlPreview,'Position',pnlpos);

% Resize the preview axis & the rulers
resizePreviewAxes(axPreview, fig);
% Resize the preview image
resizePreviewImage(axPreview, fig)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function resizePreviewAxes(axPreview, fig) 
figPreview = ancestor(axPreview, 'figure');
pnlPreview = findobj(figPreview,'Tag','PanelPreviewAxes');
pos = getpixelposition(pnlPreview);
rulerWidth = 40; %pixels
panx = findobj(figPreview, 'Type', 'uicontrol', 'Tag', 'PreviewPanx');
pany = findobj(figPreview, 'Type', 'uicontrol', 'Tag', 'PreviewPany');
props = getappdata(axPreview, 'PrintProperties');
paperSize = props.PaperSize;

%Fit to window scale
zoom = getappdata(axPreview, 'ZoomFactor');
if isempty(zoom) %Fit to window
  pixperinch = min(pos(3)/paperSize(1), pos(4)/paperSize(2));
else
  zoom = hgconvertunits(handle(figPreview),[0 0 1 zoom],props.PaperUnits,'inches',get(figPreview, 'Parent'));
  posInches = hgconvertunits(handle(figPreview),pos,'pixels','inches',figPreview);
  zoom = zoom(end);
  pixperinch = pos(3)/posInches(3) * zoom;    
end
setappdata(axPreview, 'PixelsPerInch', pixperinch);

% Get the left,bottom,width,height (position) of the axPreview
px = get(panx, 'Value');
py = get(pany, 'Value');
axwidth = pixperinch*paperSize(1);
axheight = pixperinch*paperSize(2);
axleft = 0.5*(pos(3)-axwidth);
axbottom = 0.5*(pos(4)-axheight);
if axleft<0
    axleft = -px*(axwidth-pos(3)); 
end
if axbottom<0
    axbottom = -py*(axheight-pos(4)); 
end

%Set the SliderStep correctly
widthratio = pos(3)/axwidth;
if widthratio<1 
    percent = 1/(1/widthratio-1); 
else 
    percent = inf;
end
set(panx, 'SliderStep', [0.01 percent]);
percent = pos(4)/axheight;
if percent<1
    percent = 1/(1/percent-1); 
else 
    percent = inf; 
end

set(pany, 'SliderStep', [0.01 percent]);

pnlPreview = get(axPreview,'Parent');
ppos = get(pnlPreview,'Position');

% Set the positions of the preview axis & the rulers correctly
set(axPreview, 'Position', [axleft axbottom axwidth axheight],...
    'XLim', [0 paperSize(1)], 'YLim', [0 paperSize(2)]);
axRulerVer = getappdata(axPreview, 'RulerVertical');
axRulerHor = getappdata(axPreview, 'RulerHorizontal');
verpos = [30, ppos(2)+axbottom, rulerWidth-30, axheight];
verlim = [0 paperSize(2)];
if axbottom < 0 || axheight > ppos(4)
    verlim(1) = (axbottom+axheight-ppos(4))/pixperinch;
    verlim(2) = verlim(1) + ppos(4)/pixperinch;
    verpos([2 4]) = ppos([2 4]);
end
horpos = [axleft+ppos(1), ppos(2)+ppos(4)+10, axwidth, rulerWidth-30];
horlim = [0 paperSize(1)];
if axleft < 0 || axwidth > ppos(3)
    horlim(1) = -axleft/pixperinch;
    horlim(2) = horlim(1) + ppos(3)/pixperinch;
    horpos([1 3]) = ppos([1 3]);
end

set(axRulerVer, 'Position', verpos,'YLim', verlim);
set(axRulerHor, 'Position', horpos,'XLim', horlim);

%Resize the rulers
drawMarginMarker(axPreview, findobj(axRulerVer, 'Tag', 'Top'), ...
    props.PaperPosition(2));
drawMarginMarker(axPreview, findobj(axRulerVer, 'Tag', 'Bottom'), ...
    props.PaperPosition(2)+props.PaperPosition(4));
drawMarginMarker(axPreview, findobj(axRulerVer, 'Tag', 'MiddleVer'), ...
    props.PaperPosition(2)+props.PaperPosition(4)/2);
drawMarginMarker(axPreview, findobj(axRulerHor, 'Tag', 'Left'), ...
    props.PaperPosition(1));
drawMarginMarker(axPreview, findobj(axRulerHor, 'Tag', 'Right'), ...
    props.PaperPosition(1)+props.PaperPosition(3));
drawMarginMarker(axPreview, findobj(axRulerHor, 'Tag', 'MiddleHor'), ...
    props.PaperPosition(1)+props.PaperPosition(3)/2);

% Re-configure the rulers
toggleInteractiveRulers(figPreview, axPreview, fig)
             
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showHeaderAndDate(axPreview, fig)             
headertext = findall(axPreview, 'Type','text', 'Tag', 'PreviewHeader');
datetext = findall(axPreview, 'Type','text', 'Tag', 'PreviewDate');
figPreview = ancestor(axPreview, 'figure');

hs = getappdata(fig, 'PrintHeaderHeaderSpec');
if ~isempty(hs)
    gap = hgconvertunits(handle(fig), [hs.margin 0 0 0], 'points', get(fig,'PaperUnits'), fig);
    pos = hgconvertunits(handle(figPreview), getpixelposition(axPreview), ...
            'pixels', get(fig,'PaperUnits'), figPreview);
    gap = gap(1);
    paperSize = get(fig, 'PaperSize');
    zoom = pos(3)/paperSize(1);
    fontsize = hs.fontsize*zoom;
    topLeft = [gap, paperSize(2)-gap];
    topRight = [paperSize(1)-gap, paperSize(2)-gap];
    set(headertext,'Position', topLeft, ...
        'String', hs.string, 'FontName', hs.fontname, ...
        'FontUnits', 'points', 'FontSize', fontsize, ...
        'FontAngle', hs.fontangle, 'FontWeight', hs.fontweight);
    datestring = '';
    if ~strcmp(hs.dateformat,'none')
      datestring = datestr(now,hs.dateformat,'local');
    end
    set(datetext, 'Position', topRight, ...
        'String', datestring, 'FontName', hs.fontname, ...
        'FontUnits', 'points', 'FontSize', fontsize, ...
        'FontAngle', hs.fontangle, 'FontWeight', hs.fontweight);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pos = getMarkerPos(axPreview, group)
pixperinch = getappdata(axPreview, 'PixelsPerInch');
d = 2/pixperinch;
tag = get(group,'Tag');
marker = findobj(group,'Tag','Mark');
switch tag
    case {'Top','Bottom','MiddleVer'}
        markData = get(marker,'YData');
        pos = markData(1) + d;
    case {'Left','Right','MiddleHor'}
        markData = get(marker,'XData');
        pos = markData(1) + d;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function drawMarginMarker(axPreview, group, pos)
pixperinch = getappdata(axPreview, 'PixelsPerInch');
d = 2/pixperinch;
tag = get(group,'Tag');
marker = findobj(group,'Tag','Mark');
outside = findobj(group,'Tag','Out');
hit = findobj(group,'Tag','HitRegion');
dh = 3*d;
switch tag
  case 'Top'
    set(marker,'XData',[0 1 1 0],'YData',[pos-d pos-d pos+d pos+d]);
    set(hit,'XData',[0 1 1 0],'YData',[pos-dh pos-dh pos+dh pos+dh]);
    set(outside,'XData',[0 1 1 0],'YData',[pos pos -10000 -10000]);
  case 'Bottom'
    set(marker,'XData',[0 1 1 0],'YData',[pos-d pos-d pos+d pos+d]);
    set(hit,'XData',[0 1 1 0],'YData',[pos-dh pos-dh pos+dh pos+dh]);
    set(outside,'XData',[0 1 1 0],'YData',[pos pos 10000 10000]);
  case 'MiddleVer'
    set(marker,'XData',[0 1 1 0],'YData',[pos-d pos-d pos+d pos+d]);
    set(hit,'XData',[0 1 1 0],'YData',[pos-dh pos-dh pos+dh pos+dh]);
    set(outside,'XData',[0 1 1 0],'YData',[pos pos pos pos]);
  case 'Left'
    set(marker,'XData',[pos-d pos-d pos+d pos+d],'YData',[0 1 1 0]);
    set(hit,'XData',[pos-dh pos-dh pos+dh pos+dh],'YData',[0 1 1 0]);
    set(outside,'XData',[pos pos -10000 -10000],'YData',[0 1 1 0]);
  case 'Right'
    set(marker,'XData',[pos-d pos-d pos+d pos+d],'YData',[0 1 1 0]);
    set(hit,'XData',[pos-dh pos-dh pos+dh pos+dh],'YData',[0 1 1 0]);
    set(outside,'XData',[pos pos 10000 10000],'YData',[0 1 1 0]);
  case 'MiddleHor'
    set(marker,'XData',[pos-d pos-d pos+d pos+d],'YData',[0 1 1 0]);
    set(hit,'XData',[pos-dh pos-dh pos+dh pos+dh],'YData',[0 1 1 0]);
    set(outside,'XData',[pos pos pos pos],'YData',[0 1 1 0]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function resizePreviewImage(axPreview, fig)  %#ok
zoom = getappdata(axPreview, 'ZoomFactor');
if isempty(zoom)
    zoom=1; 
else 
    zoom = ceil(zoom); 
end
figPreview = ancestor(axPreview, 'figure');
props = getappdata(axPreview, 'PrintProperties');
pos = hgconvertunits(handle(figPreview), get(axPreview, 'Position'), ...
                         get(axPreview,'Units'), props.PaperUnits, figPreview);              
scale = pos(3)/props.PaperSize(1);              
img = findobj(axPreview, 'Type', 'image');

% Set the image's xdata, ydata
xdata = [props.PaperPosition(1),props.PaperPosition(1)+props.PaperPosition(3)];
ydata = [props.PaperPosition(2),props.PaperPosition(2)+props.PaperPosition(4)];
ylim = get(axPreview, 'YLim');
ydata = [ylim(2)-ydata(2) ylim(2)-ydata(1)];
set(img, 'XData', xdata, 'YData', ydata);

% Set the cdata on the image
cdata = getappdata(axPreview, 'CData');
cdata = subsamplemex(cdata,scale,zoom);
set(img, 'CData', cdata);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setPrintProps(axPreview, fig)
props = getappdata(axPreview, 'PrintProperties');
if isempty(props), return; end

%Stick these print properties in the figure (for future)
setprinttemplate(fig, props);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateImage(axPreview, fig, updateOnlyImage)
if nargin < 3, updateOnlyImage = false; end

%Get the image capture
elapse = getappdata(axPreview,'ElapseTime');
img = findobj(axPreview, 'Type', 'image');
txt = findobj(get(axPreview,'Parent'), 'Tag', 'BusyMessage');
if ~isempty(elapse) && elapse > 1
    img = findobj(axPreview, 'Type', 'image');
    set(img,'Visible','off');
    set(txt,'Visible','on','String',getString(message('MATLAB:uistring:printpreview:RecomputingPreview')));
end
haderror = false;
try
    matlab.graphics.internal.createPrintPreviewCData(axPreview, fig);
catch ex
    setappdata(axPreview, 'CData',zeros(10) );
    set(img,'Visible','off');
    set(txt,'Visible','on',...
            'String',getString(message('MATLAB:uistring:printpreview:ErrorRefreshingPreview',ex.getReport('basic'))));
    haderror = true;
end
if ~haderror && isempty(getappdata(fig,'PreviewUpdateData'))
    set(img,'Visible','on');
    set(txt,'Visible','off');
end
if ~updateOnlyImage && ~isempty(axPreview) && ishghandle(axPreview)
    resizePreviewAxes(axPreview, fig);
    resizePreviewImage(axPreview, fig);
    showHeaderAndDate(axPreview, fig);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onResize(~, ~, fig, axPreview)
if ~isempty(axPreview) && isappdata(axPreview, 'CData')  
  resizeDialog(axPreview, fig);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onJavaCallback(~, evtdata, fig, axPreview) 
action = evtdata(1);
data = evtdata(2);
switch(action)
    case 'PropertyChange'
        onPrintPropsChanged(data, fig, axPreview);    
    case 'ChangeHeaderFont'
        onChangeHeaderFont(data,fig,axPreview);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onPrintPropsChanged(evtdata, fig, axPreview)
% Make sure that the preview window has not been closed before this
% delayedCallback is called
if ~ishghandle(axPreview) || ~ishghandle(fig), return; end

% Get the NVP of properties
keys = evtdata.getKeys();
vals = evtdata.getValues();

if isempty(keys) % Request from Java to get default properties
    set(fig, 'PrintTemplate', []);
    props = ppgetprinttemplate(fig);
    evtdata.initialize(-1, -1, fieldnames(props), struct2cell(props));    
    refreshGUI(axPreview,fig,props);
else
    nfields = length(keys);
    t = cell(2,nfields);
    t(1,:) = keys(1:nfields);
    t(2,:) = vals(1:nfields);
    props = struct(t{:});
    % remember data for the update timer
    figPreview = ancestor(axPreview,'figure');
    setappdata(figPreview,'PreviewUpdateData',props);    
end

updateFigSize(axPreview, fig);

function onRefresh(~, ~, axPreview, fig) 
if ~ishghandle(axPreview) || ~ishghandle(fig), return; end
figPreview = ancestor(axPreview,'figure');
props = getappdata(figPreview,'PreviewUpdateData');

% Optimize the refreshGUI calls
% Do not refresh is pdate data is same as previous run
if isappdata(figPreview,'PreviewUpdateData_Old')
    propsOld  = getappdata(figPreview,'PreviewUpdateData_Old');
else
    propsOld = [];
end

if ~isempty(props) && ~isequal(propsOld, props)
    setappdata(figPreview,'PreviewUpdateData',[]);
    setappdata(figPreview,'PreviewUpdateData_Old',props);
    try
        refreshGUI(axPreview,fig,props);
    catch %#ok<CTCH>
    end
end

function refreshGUI(axPreview,fig,props)
propsOld = getappdata(axPreview, 'PrintProperties');
setappdata(axPreview, 'PrintProperties', props);
setPrintProps(axPreview, fig);
if ~strcmp(propsOld.PaperOrientation, props.PaperOrientation)
    resizePreviewAxes(axPreview, fig);
end
if ~strcmp(props.StyleSheet, 'default')
    drawnow;
    if ishghandle(axPreview) && ishghandle(fig)
        updateImage(axPreview, fig);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onChangeHeaderFont(evtdata, fig, axPreview)

% Make sure that the preview window has not been closed before this
% delayedCallback is called
if ~ishghandle(axPreview) || ~ishghandle(fig), return; end

% Get the NVP of properties
keys = evtdata.getKeys();
vals = evtdata.getValues();

nfields = length(keys);
t = cell(2,nfields);
t(1,:) = keys(1:nfields);
t(2,:) = vals(1:nfields);
props = struct(t{:});

if isfield(props, 'HeaderFontName')
  font.FontName = props.HeaderFontName; 
else
  font.FontName = get(0,'DefaultTextFontName');
end
font.FontUnits = 'points';
if isfield(props, 'HeaderFontSize')
  font.FontSize = props.HeaderFontSize;
else
  font.FontSize = 10;
end
if isfield(props, 'HeaderFontAngle')
  font.FontAngle = props.HeaderFontAngle;
else
  font.FontAngle = 'normal';
end
if isfield(props, 'HeaderFontWeight')
  font.FontWeight = props.HeaderFontWeight;
else
  font.FontWeight = 'normal';
end   
font = uisetfont(font);
if isstruct(font) %User did not Cancel
    props.HeaderFontName = font.FontName;
    props.HeaderFontSize = font.FontSize;    
    props.HeaderFontAngle = font.FontAngle;
    props.HeaderFontWeight = font.FontWeight;

    setappdata(axPreview, 'PrintProperties', props);
    setPrintProps(axPreview, fig);
    updateImage(axPreview, fig);
    evtdata.setHeaderFont(font.FontName, font.FontSize, ...
                          font.FontWeight, font.FontAngle);
    showHeaderAndDate(axPreview, fig);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function wbdown(figPreview, ~, axPreview) 
obj = hittest(figPreview);

if strcmp(get(obj,'Type'), 'patch') 
    obj = get(obj,'Parent');
    setappdata(axPreview, 'PreviewMoveObject', obj);
    setappdata(axPreview, 'ObjectMoved', false)
    onRulerMarginChanged(axPreview, obj);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function wbup(figPreview, ~, fig, javamodel, axPreview) 
if isappdata(axPreview, 'PreviewMoveObject')
    rmappdata(axPreview, 'PreviewMoveObject');
    rmappdata(axPreview, 'ObjectMoved')
    ln = findall(axPreview, 'type', 'line', 'tag', 'PreviewMargin');
    set(ln, 'Visible', 'off');
    setPrintProps(axPreview, fig);
    updateImage(axPreview, fig);
    props = getappdata(axPreview, 'PrintProperties');
    javamodel.initialize(-1, -1, fieldnames(props), struct2cell(props));
end
% We won't catch a mouse motion event over java components, so double check 
% cursor that's set. 
setCursor(figPreview); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function wbmotion(figPreview, ~, fig, axPreview) 
if isappdata(double(axPreview), 'PreviewMoveObject')
    obj = getappdata(axPreview, 'PreviewMoveObject');
    onRulerMarginChanged(axPreview, obj);
    resizePreviewImage(axPreview, fig);
else
    setCursor(figPreview);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setCursor(figPreview) 
obj = hittest(figPreview); 

if strcmp(get(obj,'Type'), 'patch') && strcmp(get(obj,'Tag'),'Mark')
    set(figPreview, 'Pointer', getappdata(get(obj,'Parent'),'Pointer')); 
else 
    set(figPreview, 'Pointer', 'arrow'); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onRulerMarginChanged(axPreview, h)
figPreview = ancestor(axPreview, 'figure');
point = get(figPreview, 'CurrentPoint');
axPos = getpixelposition(axPreview,true);
xlim = get(axPreview, 'XLim');
ylim = get(axPreview, 'YLim');
x = (point(1)-axPos(1))*xlim(2)/axPos(3);
y = (point(2)-axPos(2))*ylim(2)/axPos(4);
y = ylim(2)-y;
props = getappdata(axPreview, 'PrintProperties');
ln = findall(axPreview, 'Type', 'line', 'Tag', 'PreviewMargin');

scale = axPos(3)/xlim(2);
d = 2/scale;
moving = getappdata(axPreview,'ObjectMoved');
ruler = ancestor(h,'axes');
ticks = get(ruler,'XTick');
if isempty(ticks)
    ticks = get(ruler,'YTick');
end
step = unitstepsize(props.PaperUnits,ticks);
switch get(h,'Tag')
  case 'Left'
    right = props.PaperPosition(1)+props.PaperPosition(3);    
    if abs(x-right) > 4*d, moving = true; end
    x = round(x/step)*step;
    % If x would be less than one step away from the middle, stop moving:
    h1 = findobj(get(h,'Parent'),'Tag','MiddleHor');
    xM = getMarkerPos(axPreview,h1);
    % If the distance between the proposed x and the middle ruler is less
    % than one step, don't allow the move. Since the left marker should
    % always have a smaller X than the middle marker, make sure the distance
    % is non-negative and greater than a single step.
    if xM - x < step
        moving = false;
    end
    if moving && x < xlim(2) && x > xlim(1)
        drawMarginMarker(axPreview, h, x);
        set(ln,'XData',[x x],'YData',ylim,'Visible','on');    
        props.PaperPosition(1) = x;
        props.PaperPosition(3) = right-x;
        % draw other markers
        drawMarginMarker(axPreview, h1, x+props.PaperPosition(3)/2);
    end
  case 'Right'
    if abs(x-props.PaperPosition(1)) > 4*d, moving = true; end
    x = round(x/step)*step;
    h1 = findobj(get(h,'Parent'),'Tag','MiddleHor');
    xM = getMarkerPos(axPreview,h1);
    % If the distance between the proposed x and the middle ruler is less
    % than one step, don't allow the move. Since the right marker should
    % always have a larger X than the middle marker, make sure the distance
    % is non-negative and greater than a single step.
    if x - xM < step
        moving = false;
    end
    if moving && x < xlim(2) && x > xlim(1)
        drawMarginMarker(axPreview, h, x);
        set(ln,'XData',[x x],'YData',ylim,'Visible','on');
        props.PaperPosition(3) = x-props.PaperPosition(1);
        % draw other markers
        drawMarginMarker(axPreview, h1, x-props.PaperPosition(3)/2);
    end
  case 'MiddleHor'
    half = props.PaperPosition(3)/2;
    mid = props.PaperPosition(1) + half;
    if abs(x-mid) > 4*d, moving = true; end
    x = round(x/step)*step;
    if moving && x < xlim(2) && x > xlim(1)
        drawMarginMarker(axPreview, h, x);
        set(ln,'XData',[x x],'YData',ylim,'Visible','on');
        props.PaperPosition(1) = x-props.PaperPosition(3)/2;
        % draw other markers
        h1 = findobj(get(h,'Parent'),'Tag','Left');
        drawMarginMarker(axPreview, h1, x - half);
        h2 = findobj(get(h,'Parent'),'Tag','Right');
        drawMarginMarker(axPreview, h2, x + half);
    end
  case 'Top'
    bottom = props.PaperPosition(2)+props.PaperPosition(4);
    if abs(y-bottom) > 4*d, moving = true; end
    y = round(y/step)*step;
    h1 = findobj(get(h,'Parent'),'Tag','MiddleVer');
    yM = getMarkerPos(axPreview,h1);
    % If the distance between the proposed y and the middle ruler is less
    % than one step, don't allow the move. Since the top marker should
    % always have a smaller Y than the middle marker, make sure the distance
    % is non-negative and greater than a single step.
    if yM - y < step
        moving = false;
    end    
    if moving && y < ylim(2) && y > ylim(1)
        drawMarginMarker(axPreview, h, y);
        set(ln,'XData',xlim,'YData',[ylim(2)-y ylim(2)-y],'Visible','on');    
        props.PaperPosition(2) = y;
        props.PaperPosition(4) = bottom-y;
        % draw other markers
        drawMarginMarker(axPreview, h1, y+props.PaperPosition(4)/2);
    end
  case 'Bottom'
    if abs(y-props.PaperPosition(2)) > 4*d, moving = true; end
    y = round(y/step)*step;
    h1 = findobj(get(h,'Parent'),'Tag','MiddleVer');
    yM = getMarkerPos(axPreview,h1);
    % If the distance between the proposed y and the middle ruler is less
    % than one step, don't allow the move. Since the bottom marker should
    % always have a larger Y than the middle marker, make sure the distance
    % is non-negative and greater than a single step.
    if y - yM < step
        moving = false;
    end   
    if moving && y < ylim(2) && y > ylim(1)
        drawMarginMarker(axPreview, h, y);
        set(ln,'XData',xlim,'YData',[ylim(2)-y ylim(2)-y],'Visible','on');
        props.PaperPosition(4) = y-props.PaperPosition(2);
        % draw other markers
        drawMarginMarker(axPreview, h1, y-props.PaperPosition(4)/2);
    end
  case 'MiddleVer'
    half = props.PaperPosition(4)/2;
    mid = props.PaperPosition(2) + half;
    if abs(y-mid) > 4*d, moving = true; end
    y = round(y/step)*step;
    if moving && y < ylim(2) && y > ylim(1)
        drawMarginMarker(axPreview, h, y);
        set(ln,'XData',xlim,'YData',[ylim(2)-y ylim(2)-y],'Visible','on');
        props.PaperPosition(2) = y-props.PaperPosition(4)/2;
        % draw other markers
        h1 = findobj(get(h,'Parent'),'Tag','Top');
        drawMarginMarker(axPreview, h1, y - half);
        h2 = findobj(get(h,'Parent'),'Tag','Bottom');
        drawMarginMarker(axPreview, h2, y + half);
    end
end
setappdata(axPreview,'ObjectMoved',moving);
setappdata(axPreview,'PrintProperties',props);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onPrint(src, evt, fig) %#ok
printdlg(fig);
%Bring the preview window toFront
figPreview = getappdata(fig, 'PrintPreview');
if ishghandle(figPreview)
    figure(figPreview);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateFigSize(axPreview, fig)
figPreview = ancestor(axPreview,'figure');
model = getappdata(figPreview,'JavaModel');
if ~isempty(model)
    figSize = hgconvertunits(handle(fig), get(fig, 'Position'), ...
        get(fig, 'Units'), char(getUnits(model)), get(fig, 'Parent'));
    javaFigSize = model.getFigSize;
    % If the figure size has changed since the last refresh, update it in
    % the java model.
    if ~isequal(javaFigSize,[figSize(3);figSize(4)])
        awtinvoke(model,'setFigSize(Ljava.lang.Object;DD)',[],figSize(3),figSize(4));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onClose(src, evt, figPreview) %#ok
delete(figPreview);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onHelp(src, evt) %#ok
helpview(fullfile(docroot, 'matlab', 'ref', 'printpreview.html'), 'CSHelpWindow');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onPaperZoom(src, evt, axPreview, fig) %#ok
comboZoom = get(evt, 'Source');
value = comboZoom.getSelectedItem();

if comboZoom.getSelectedIndex() == comboZoom.getItemCount()-1
    % last item is Overview as a localized string
    if isappdata(axPreview, 'ZoomFactor')
      rmappdata(axPreview, 'ZoomFactor');
      updateImage(axPreview, fig);
    end
else
    d = str2double(value);
    if ~isnan(d)
      setappdata(axPreview, 'ZoomFactor', d/100.0);
      updateImage(axPreview, fig);      
    else
      warndlg(getString(message('MATLAB:uistring:printpreview:DialogStringThisIsNotAValidMeasurement')), getString(message('MATLAB:uistring:printpreview:DialogTitlePrintPreviewWarning')), 'modal');
      oldval = getappdata(axPreview, 'ZoomFactor');
      if isempty(oldval)
          oldval = 'Fit'; 
      else 
          oldval=num2str(oldval*100); 
      end
      awtinvoke(comboZoom,'setSelectedItem(Ljava/lang/Object;)',oldval);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function onScroll(src,evt,axPreview,fig) %#ok
resizePreviewAxes(axPreview, fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g = makeMarker(parent,tag,color,pointer)
g = hgtransform('parent',parent,'Hittest','off','Tag',tag);
setappdata(g,'Pointer',pointer);

patch('Parent', g, 'Tag', 'Out','FaceColor',color,'HitTest','on');
patch('Parent', g, 'Tag', 'HitRegion','FaceColor','none','EdgeColor','none');
patch('Parent', g, 'Tag', 'Mark','HitTest','on');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pt = appendPropsFromFigToPrintTemplate(pt,h)

pt.StyleSheet = 'default';
% Get the default paper information from the appdata.
if isappdata(h,'PrintDefaultPaperInformation')
    ptInfo = getappdata(h,'PrintDefaultPaperInformation');
else
    % version 1 is R12 through R2006a, version 2 is after R2006b
    ptInfo.VersionNumber = 2;
    ptInfo.FontName = '';
    ptInfo.FontSize = 0;
    ptInfo.FontSizeType = 'screen';
    ptInfo.FontAngle = '';
    ptInfo.FontWeight = '';
    ptInfo.FontColor = '';
    ptInfo.LineWidth = 0;
    ptInfo.LineWidthType = 'screen';
    ptInfo.LineMinWidth = 0;
    ptInfo.LineStyle = '';
    ptInfo.LineColor = '';
    ptInfo.PrintActiveX = 0;
    ptInfo.GrayScale = 0;
    ptInfo.BkColor= 'white';
    ptInfo.DriverColor = defaultprtcolor(h);
    % get the papertype,size, orientation, etc. from the figure
    ptInfo.PaperType = get(h, 'PaperType');
    ptInfo.PaperSize = get(h, 'PaperSize');
    ptInfo.PaperOrientation = get(h, 'PaperOrientation');
    ptInfo.PaperUnits = get(h, 'PaperUnits');
    paperPosition = get(h, 'PaperPosition');
    ptInfo.PaperPosition = [paperPosition(1), ...
        ptInfo.PaperSize(2) - (paperPosition(2) + paperPosition(4)), ...
        paperPosition(3), ...
        paperPosition(4)];
    ptInfo.PaperPositionMode = get(h, 'PaperPositionMode');

    ptInfo.FigSize = hgconvertunits(handle(h), get(h, 'Position'), ...
        get(h, 'Units'), ptInfo.PaperUnits, get(h, 'Parent'));
    
    ptInfo.FigSize = ptInfo.FigSize(3:4);
    ptInfo.InvertHardCopy = get(h, 'InvertHardcopy');
    setappdata(h,'PrintDefaultPaperInformation',ptInfo);
end
fNames = fieldnames(ptInfo);
for i = 1:numel(fNames)
    pt.(fNames{i}) = ptInfo.(fNames{i});
end

% get the figure header info...
if isappdata(h, 'PrintHeaderHeaderSpec')
    headerInfo = getappdata(h, 'PrintHeaderHeaderSpec'); 
    pt.HeaderText = headerInfo.string;
    pt.HeaderDateFormat = headerInfo.dateformat;
    pt.HeaderFontName = headerInfo.fontname;
    pt.HeaderFontSize = headerInfo.fontsize;
    pt.HeaderFontAngle = headerInfo.fontangle;
    pt.HeaderFontWeight = headerInfo.fontweight;
    pt.HeaderMargin = headerInfo.margin;
else
    pt.HeaderText = '';
    pt.HeaderDateFormat = 'none';
end


function props = ppgetprinttemplate(fig)
props = getprinttemplate(fig);
if isempty(props) || ~isequal(props.VersionNumber,2)
    if isempty(props)
        props = printtemplate;
    end
    props = appendPropsFromFigToPrintTemplate(props,fig);
end

function step = unitstepsize(units,ticks)
switch units
  case 'inches'
    scale = 1/8;
  otherwise
    scale = 1/10;
end
if length(ticks) < 2, ticks = [0 1]; end
step = (ticks(2)-ticks(1))*scale;
