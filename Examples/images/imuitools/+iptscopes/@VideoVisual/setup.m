function setup(this, hVisParent)
%SETUP Setup the Visual

%   Copyright 2007-2017 The MathWorks, Inc.

hAxes = axes( ...
    'Tag', 'VisualAxes',...
    'Parent',hVisParent, ...
    'OuterPosition',[0 0 1 1], ...
    'Layer','bottom',...
    'NextPlot','add');

if ~isa(hAxes, 'matlab.graphics.axis.Axes')
    set(hAxes, 'DrawMode', 'fast');
end

axesProps = this.Registration.PropertySet.findProperty('AxesProperties').Value;
if ~isempty(axesProps)
    
    xlabel(hAxes, axesProps.XLabel, 'Color', axesProps.XColor);
    ylabel(hAxes, axesProps.YLabel, 'Color', axesProps.XColor);
    zlabel(hAxes, axesProps.ZLabel, 'Color', axesProps.XColor);
    title(hAxes, axesProps.Title,   'Color', axesProps.XColor);
    
    set(hAxes, rmfield(axesProps, {'XLabel', 'YLabel', 'ZLabel', 'Title', 'FontName'}));
end

this.Axes = hAxes;

hgaddbehavior(hAxes, uiservices.getPlotEditBehavior('select'));

defaultN = 1;

% Setup the default axes for video display.
set(this.Axes, ...
    'Parent',hVisParent, ...
    'Position',[0 0 1 1], ...
    'Visible','off', ...
    'XLim',[0.5 0.5+defaultN], ...
    'YLim', [0.5 0.5+defaultN], ...
    'YDir','reverse', ...
    'XLimMode','manual',...
    'YLimMode','manual',...
    'ZLimMode','manual',...
    'CLimMode','manual',...
    'ALimMode','manual',...
    'Layer','bottom',...
    'NextPlot','add', ...
    'DataAspectRatio',[1 1 1]);

% Create the image object.
this.Image = image(...
    'XData', [1 1], ...
    'YData', [1 1], ...
    'Tag', 'VideoImage',...
    'Parent',this.Axes, ...
    'CData',zeros(defaultN,defaultN,'uint8'));

hgaddbehavior(this.Image, uiservices.getPlotEditBehavior('select'));

% Create the color map dialog.  We defer the creation of the colormap to
% here so that it can update the figure's colormap now that it is rendered.
this.ColorMap = matlabshared.scopes.visual.ColorMap(this);
updateColorMap(this);

% Listen for changes in colormap scaling
this.ScalingChangedListener = event.listener(this.ColorMap, ...
    'ScalingChanged', @(hMap, ev) postColorMapUpdate(this));

% Update tooltip to react to current data format settings
hGUI = this.Application.getGUI;
if isempty(hGUI)
    hDims = this.DimsStatus;
else
    hDims = hGUI.findwidget({'StatusBar','StdOpts','iptscopes.VideoVisual Dims'});
end
hDims.Tooltip = getString(message('Spcuilib:scopes:ToolTipColorFormat'));
hDims.Tag = 'ColorFormatStatus';

% Update callback to open video info dialog
hDims.Callback = @(hco,ev) show(this.VideoInfo, true);

this.ScrollPanel = imscrollpanel(get(this.Axes, 'Parent'), this.Image);
set(this.ScrollPanel, 'Units', 'normalized', ...
    'HitTest', 'off');
set(this.Axes,'Tag', 'VideoAxes');

% Update extension
this.Extension = this.Application.getExtInst('Tools:Image Navigation Tools');

% When there is a datasource use it to help setup the scrollpanel,
% otherwise this will get called from a listener.
if ~isempty(this.Application.DataSource)
    dataSourceChanged(this);
end

% [EOF]