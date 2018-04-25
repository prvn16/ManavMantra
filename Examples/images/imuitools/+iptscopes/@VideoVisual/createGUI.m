function hInstall = createGUI(this)
%CREATEGUI Create the video specific UIMgr components.

%   Copyright 2007-2016 The MathWorks, Inc.

if ispc
    w = 80;
else
    w = 104;
end

hDims = uimgr.uistatus(sprintf('%s Dims', class(this)));
hDims.setWidgetPropertyDefault('Width', w);
hDims.Placement = -2;

plan = {hDims, 'Base/StatusBar/StdOpts'};

% plan{1}.WidgetProperties = {plan{1}.WidgetProperties, ...
%     'Tooltip', sprintf('Color Format: Height x Width'), ...
%     'Callback', @(hco,ev) show(this.VideoInfo, true)};


mInfo = uimgr.uimenu('VideoInfo',-inf,getString(message('Spcuilib:scopes:MenuVidInfo')));
mInfo.setWidgetPropertyDefault(...
    'Callback', @(hco,ev) show(this.VideoInfo, true));

mColormap = uimgr.uimenu('Colormap',inf,getString(message('Spcuilib:scopes:MenuColorMap')));

hSource = this.Application.DataSource;
if isempty(hSource) || ~isDataLoaded(hSource) || isRGB(hSource)
    ena = 'off';
else
    ena = 'on';
end
mColormap.Enable = ena;
mColormap.setWidgetPropertyDefault(...
    'Callback', @(hco,ev) show(this.ColorMap, true));

%  Place Video Info first
hVideoInfo = uimgr.uipushtool('VideoInfo',-inf);
hVideoInfo.IconAppData = 'info';
hVideoInfo.setWidgetPropertyDefault(...
    'BusyAction','cancel', ...
    'TooltipString',getString(message('Spcuilib:scopes:ToolTipVidInf')), ...
    'ClickedCallback', @(hco,ev) show(this.VideoInfo, true));

hKeyPlayback = uimgr.spckeygroup(getString(message('Spcuilib:scopes:TitleVideo')));
hKeyPlayback.add( ...
    uimgr.spckeybinding('colormap','C',...
    @(h,ev) showColormapDialog(this), getString(message('Spcuilib:scopes:LabelChangeColorMap'))),...
    uimgr.spckeybinding('videoinfo','V',...
    @(h,ev) show(this.VideoInfo, true), getString(message('Spcuilib:scopes:LabelDisplayVideoInfo'))));

mVideoTools = uimgr.uimenugroup('VideoTools', -inf, mInfo, mColormap);

hInstall = uimgr.Installer({plan{:}; ...
    mVideoTools, 'Base/Menus/Tools'; ...
    hVideoInfo, 'Base/Toolbars/Main/Tools/Standard'; ...
    hKeyPlayback, 'Base/KeyMgr'});

% -------------------------------------------------------------------------
function b = isRGB(hSource)

b = getNumInputs(hSource) == 3;

if ~b
    maxDimensions = getMaxDimensions(hSource, 1);
    b = numel(maxDimensions) == 3 && maxDimensions(3) == 3;
end

% -------------------------------------------------------------------------
function showColormapDialog(this)

hSrc = this.Application.DataSource;
if ~isempty(hSrc) && isDataLoaded(hSrc) && ~isRGB(hSrc)
    show(this.ColorMap, true)
end

% [EOF]

% LocalWords:  UI hco ev videoinfo