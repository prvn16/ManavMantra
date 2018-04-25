function createHistogramUI(ntx)
% Called by CreateGUI to create histogram display region
% Creates and add widget handles to UserData
%
% No features such as dialog panel or DTX are added here
% No initialization of graphics for user

%   Copyright 2010-2014 The MathWorks, Inc.

dp = ntx.dp; % Get handle to DialogPanel

% --- HISTOGRAM

% Register histogram's local context menu handler with DialogPanel
setBodyPanelContextMenuFcn(dp, ...
    @(hParent,hContext)buildContextMenu(ntx,hContext));

% Clip BarWidth to the range (0,1]
if ntx.HistBarWidth<=0
    ntx.HistBarWidth=0.5;
elseif ntx.HistBarWidth>1
    ntx.HistBarWidth=1;
end

% xMin and xMax are scalars indicating the minimum and maximum x-axis
% value limits to be displayed, in data space coordinates as described
% below.  yMax is a scalar value, from 0 to 100 percent, to be displayed
% on y-axis, and suggests the maximum height of any single histogram bar.

% Define initial x-axis tick range,
% specified in powers of 2
xMin = -1; % 2^-1
xMax = +2; % 2^1

% Define initial x-axis limits for display (beyond ticks)
%  (initial position of underflow and overflow lines, too)
%
% These don't matter in terms of precise numbers, since resize will update
% the limits itself.
gapWidth = 1-ntx.HistBarWidth;
ax_xMin = xMin-gapWidth/2;
ax_xMax = xMax-gapWidth/2;

% Compute often-used gap width
ntx.BarGapCenter = gapWidth/2;

% Establish y-axis limits
% Histogram data will occupy ~75% of the axis height
% depending on another scale factor
ax_yMax = 10; % dummy value

% Get a few DialogPanel-specific handles for application code use:
hBodyPanel = dp.hBodyPanel;
hContextMenu = dp.hContextMenu;

% Define background color for widgets
bg = get(hBodyPanel,'BackgroundColor');

% Create histogram axes within DialogPanel body panel
hax = axes( ...
    'Parent',hBodyPanel, ...
    'Color', 'w',...
    'TickDir','out', ...
    'Units','pixels', ...
    'XDir','rev', ...
    'Visible','Off',...
    'Tag','HistogramAxis', ... % implies the default context menu
    'UIContextMenu',hContextMenu, ...
    'XTickLabel','', ...
    'XLim',[ax_xMin ax_xMax], ...
    'YLim',[0 ax_yMax]);

% Set axes within hBodyPanel in pixel units
%
% left margin:
%   margin before label: 0.5 char
%   y-label: 1 char wide (height)
%   margin between label and tick labels: 0.75 char
%   y-tick labels: 1.25 chars wide
%    (this is tricky: the measure of "1.25 char" means 1.25 char in height,
%     but we are allocating space for ~2 chars in width --- it's about
%     equivalent to 1.25 char in height, roughly)
%   margin between tick label and tick: 0.5 char
%   vertical axis line and tick mark: 0.5 char
%     total = 4.5 chars
ppc = getPPC(hax);
left_margin_pix = 4.5 * ppc;

% right margin:
%   pixels between hBodyPanel and hDialogPanel
right_margin_pix = 2;

% top margin:
%   margin above label: 1 char
%   title label: 1 char
%   margin between axis top and label: 0.5 char
%     total = 2.5 char
top_margin_pix = 2.5 * ppc;

% bottom margin:
%   margin below label: 0.5 char
%   x-label: 1 char high
%   margin between label and tick labels: 0.5 char
%   x-tick labels: 1.5 chars high (due to exponents)
%   margin between tick label and tick: 0.5 char
%   horiz axis line and tick mark: 0.5 char
%     total = 4.5 chars
bottom_margin_pix = 4.5 * ppc;

% Set axes within parent histogram container
%   -> ntx, hBodyPanel, hDialogPanel
%
% adjustHistAxisSize(ntx); % xxx cannot do here, need user-data set
%
histPos = get(hBodyPanel,'Position');
margins = [left_margin_pix bottom_margin_pix right_margin_pix top_margin_pix];
dx = max(1, histPos(3) - left_margin_pix - right_margin_pix);
dy = max(1, histPos(4) - top_margin_pix - bottom_margin_pix);
axpos = [left_margin_pix bottom_margin_pix dx dy];
set(hax,'Position',axpos);

% Generate bar plot
% Use a single x-value: 0 is an accurate, non-empty choice describing
% an "empty" histogram.
%
% The number of values here must correspond to the number of histogram
% entries appearing in the reset/default state.
[hBar,hlSignLine] = embedded.ntxui.NTX.dynamicBar(hax,ntx.HistBarWidth,ntx.HistBarOffset,0,ntx.ColorNormalBar);
set(hBar,'Tag','HistogramBars');

% Create negative-value barplot
% Need to pass two zeros as a bug fix for color
hBarNeg = embedded.ntxui.NTX.dynamicBar(hax,ntx.HistBarWidth,ntx.HistBarOffset,0,ntx.ColorOverflowBar);
set(hBarNeg,'FaceColor',ntx.ColorOverflowBar,'Tag','HistogramNegOverflowBars');

% Create positive-value barplot. Positive values on MSB of signed type will
% overflow.
% Need to pass two zeros as a bug fix for color
hBarPos = embedded.ntxui.NTX.dynamicBar(hax,ntx.HistBarWidth,ntx.HistBarOffset,0,ntx.ColorOverflowBar);
set(hBarPos,'FaceColor',ntx.ColorOverflowBar,'Tag','HistogramPosOverflowBars');

% X-axis label
% Set dummy x,y pos, which gets corrected during resize
str = getString(message('fixed:NumericTypeScope:AbsoluteDataValuesLabelStr'));
htXLabel = text('Parent',hax, ...
    'Units','data', ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment','top', ...
    'Tag','XAxis',...
    'Visible','off',...
    'String',str, ...
    'Position', [0 0]);

% Create an off-screen text object for tick label testing
hOffscreenText = text('Parent',hax,'Visible','off');

% Title text
htTitle = uicontrol( ...
    'Parent',hBodyPanel, ...
    'BackgroundColor',bg, ...
    'TooltipString', '', ...
    'HorizontalAlignment','right', ...
    'Units','pix', ...
    'String','', ...
    'Visible','off',...
    'Style','text', ...
    'Tag','NumericTypeString', ... % used for context menu building - invoke default menu
    'UIContextMenu',hContextMenu);

% Create "Signed" text
tip = getString(message('fixed:NumericTypeScope:SignedTextToolTip'));
blankIcon = embedded.ntxui.loadBlankIcon;
htSigned = uicontrol( ...
    'Parent',hBodyPanel, ...
    'BackgroundColor',bg, ...
    'TooltipString', tip, ...
    'Units','pix', ...
    'String','', ...
    'Visible','off',...
    'Style','checkbox', ...
    'Tag','SignedText',...
    'CData',blankIcon); 

% Create "too narrow to show histogram" text
% Be careful NOT to parent this to hBodyPanel;
%  it MUST be parented to hParent.
% We turn off visibility of hBodyPanel, but expect this message to display
str = getString(message('fixed:NumericTypeScope:NarrowDisplay'));
htNoHistoTxt = uicontrol( ...
    'Parent',dp.hParent, ...
    'BackgroundColor',bg, ...
    'ForegroundColor',[.5 .5 .5],... % gray
    'Units','norm', ...
    'HorizontalAlignment','center', ...
    'Position',[.25 .25 .5 .5], ...
    'String',str, ...
    'Visible','off', ...
    'Tag','HistogramNarrowmsgTxt',...
    'Style','text'); 
set(htNoHistoTxt,'Units','pix');

% Note:
%  HG shuts off handle visibility on the axis labels
%  If we don't turn it on, we lose context menu support
hYLabel = get(hax,'YLabel');
set(hYLabel, ...
    'HandleVisibility','on', ...
    'Tag','YAxis', ... % used for context menu building
    'UIContextMenu',hContextMenu);
ht = get(hax,'Title');
set(ht,'HandleVisibility','on');

% Histogram handles
% Cache handles we'll need for updates
%
ntx.hFig           = dp.hFig;      % copy to Body for convenience
ntx.hHistAxis      = hax;          % kept in pixel units
ntx.hTicks         = [];           % vector of text widgets handles
ntx.htXLabel       = htXLabel;
ntx.htTitle        = htTitle;
ntx.htSigned       = htSigned;
ntx.htNoHistoTxt   = htNoHistoTxt;
ntx.hOffscreenText = hOffscreenText;
ntx.hBar           = hBar;         % barplot handle, pos+neg
ntx.hBarNeg        = hBarNeg;      % barplot handle, negative only
ntx.hBarPos        = hBarPos;      % barplot handle, positive only
ntx.hlSignLine     = hlSignLine;   % overlay line handle
ntx.BinCountVerticalUnitsStr = ''; % 'thousands', etc
ntx.BlankIcon      = blankIcon;
ntx.WarnIcon       = embedded.ntxui.loadWarnIcon;
ntx.IsSigned       = false;  % gets updated in updateSignedStatus()

% How to treat "small" negative values: underflow or overflow?
% (negative values with magnitudes < eps in the given data type, such that
% rounding could force them to zero)
% This is set based on the rounding mode (floor, ceil, nearest, etc)
ntx.SmallNegAreOverflow = false;

% Enable dragging of horizontal word-size line
ntx.EnableWordSizeLineDrag = false;

% Record axis margins, in pixels
%   [ left_margin_pix, bottom_margin_pix, ...
%     right_margin_pix, top_margin_pix ]
ntx.Margins = margins;

% Create out-of-range bin indicators
% Returns a vector of 2 handles
%
% Sets ntx.hXRangeIndicators
createOutOfRangeBins(ntx);

% Scale factor in range [0,1]
% Sets maximum Y-axis placement of peak of histogram data
%   0=half display height
%   1=just below lowest readout text line (under/overflow text)
ntx.DataPeakYScaling = 1.0;

% Allow x-axis to autoscale the displayed limits
%
ntx.XAxisAutoscaling = true;
ntx.XAxisDisplayMin = ax_xMin;
ntx.XAxisDisplayMax = ax_xMax;

% Track mouse transitions from outside to inside axes
% and vice-versa.  This influences the axes display,
% locking the x-axis scaling, etc
%
ntx.MouseInsideAxes = false;

% Used to suppress updates of the vertical axis units-string
% (e.g., 'Thousands', 'Millions', etc)
% Normal range is an integer >= 0
% Default is -1, which won't match any new value and forces a change
ntx.LastYAxisPowerOf1000 = -1;

% Establish RadixPt position
% This is the x-axis point at which the radix line should appear.
% Graphical measurements relative to the radix are based on this value.
% This does NOT include the gap-width "below" start of 2^0 bin
%
ntx.RadixPt = 0; 

function ppc = getPPC(hax)
% Return height of one char in pixels (pixels per char)

pixels_per_inch = get(0,'ScreenPixelsPerInch');
inches_per_point = 1/72;
points_per_char = get(hax,'FontSize');
ppc = pixels_per_inch * inches_per_point * points_per_char;
