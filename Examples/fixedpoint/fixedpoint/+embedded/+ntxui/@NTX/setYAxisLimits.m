function setYAxisLimits(ntx)
% Set the Y-axis data range limit
% Re-initialize display

%   Copyright 2010 The MathWorks, Inc.

% Scale factor strings
% 1=Thou, 1=Mil, 3=Bil, 4=Tril ... stops at 4
unitsStrs = {'','Thousands','Millions','Billions','Trillions'};
NunitsStrs = numel(unitsStrs);

ymax_data = max(ntx.BinCounts);

displayUnits = ntx.HistVerticalUnits; % 1=percentage, 2=bin count
if displayUnits==1
     % Percentage
     if ymax_data==0
         % If max=0 then sum(data)=0, and we'll divide by 0
         % if we don't override this here
         %
         % This is the best answer if we next get a single scalar data
         % value.  One value, no matter what it is, will get binned into
         % just one bin, and that bin will represent 100% of the data.
         ymax_data_scaled = 100;
     else
         ymax_data_scaled = 100*ymax_data/ntx.DataCount;
     end
     powerOf1000 = 0; % scale factor is 1x
else
    % Bin count
    % Assume one count minimum
    ymax_data_scaled = max(1,ymax_data);
    
    % Apply thousands/millions/etc scaling
    %
    
    % Find "nearest power of 1000" for engineering-units scaling
    Ndigits = floor(log10(ymax_data_scaled)+1);
    powerOf1000 = floor((Ndigits-1)/3); % 1=1e3, 2=1e6, 3=1e9, etc
    
    % Limit ourselves to the defined set of scales/strings
    powerOf1000 = min(powerOf1000,NunitsStrs);
end

% Get axis height in pixels
hax = ntx.hHistAxis;
set(hax,'Units','pix'); % xxx unneeded -- already in pixel units
pos_pix = get(hax,'Position'); % axis position, in pixels

% Failsafe for HG bug:
if any(isnan(pos_pix))
    % Bad axis height - reset it
    set(hax, ...
        'Units','norm', ...
        'Position',get(0,'DefaultAxesPosition'));
    set(hax,'Units','pixels');
    return
end

% Early return if figure is too short
axheight_pix = pos_pix(4);
if (axheight_pix <= 0)
    return
end

% axheight_pix is the total axis height, in pixels
%
% dataheight_pix is the portion of the total axis height that the
% data should occupy.  This is BELOW the threshold text lines, if
% DTX is turned on.

% As a constraint on the height of the histogram bars, we use the
% lower 'extent' of bottom-most text in the DTX readout display,
% which is the bottom coordinate of the over- or under-threshold cursor
% text.  When one is invis, the other one gets used.  If both are
% being displayed, it doesn't matter which one we refer to as both are
% the same height.
set([ntx.htUnder ntx.htOver],'Units','pix');
extO = get(ntx.htOver,'Extent');
extU = get(ntx.htUnder,'Extent');

% Subtract 10% of vertical extent of text to account for "descender"
% area below text, which may interfere with bars when opaque background
% color is turned on
maxdataheight_pix = min(extO(2),extU(2))- 0.1*max(extO(4),extU(4));

% Define a minimum pixel height, below which we shut down the DTX display
% due to display clutter.
minPixHeight = axheight_pix/2; 
if maxdataheight_pix <= minPixHeight  % xxx set to min pixel height we want to see, eg, 20
    maxdataheight_pix = minPixHeight; % xxx set to, say, 20 - same as above
end

% Target pixel height for maximum data peak is between
% (maxdataheight_pix) and (axheight_pix/2)
%
% Alt 1: fixed height,
%   halfway between (axheight_pix/2) and (maxdataheight_pix)
%
% ymax_data_pix = (maxdataheight_pix+axheight_pix/2)/2;

% Alt 2: adjustable
% Allow adjustment of where current data peak should fall
% by setting 0<=alpha<=1
% alpha=0: peak will fall at lower axheight threshold (axheight*0.2)
% alpha=1: peak will fall at maxdataheight
%
alpha = ntx.DataPeakYScaling; % [0,1], with 0.5 typical
lower_axheight_pix = 0.2*axheight_pix;
ymax_data_pix = lower_axheight_pix + ...
    (maxdataheight_pix-lower_axheight_pix)*alpha;
if ymax_data_pix <= 0
    % Cannot use 0 as scaling factor
    ymax_data_pix = 1;
end

% We want ymax_data_scaled to render at ymax_data_pix
% Assume those are set equal (data coords <-> pixel coords)
% Then the TOP of the axis limit, in pixel units, is:
ylim_axis_data = ymax_data_scaled * ...
    (axheight_pix / ymax_data_pix);

% Reset y-axis limits
if ylim_axis_data==0
    ylim_axis_data = 1;
end
set(hax,'YLim',[0 ylim_axis_data]);

% Setting ylim gives us the tick values without engineering units
% We grab the ticks that HG chose, then scale them for our units
yt = get(hax,'YTick');
yscaleFac = 1000.^(-powerOf1000);
set(hax,'YTickLabel',yt.*yscaleFac);  % can use numbers instead of strings

% initHistDisplay() will always call updateYAxisTitle
% Here, we only need to call it if there's a change to the vertical
% units.
if powerOf1000 ~= ntx.LastYAxisPowerOf1000
    % Select the corresponding units string for vertical scaling units
    yscaleStr = unitsStrs{1 + powerOf1000};
    ntx.BinCountVerticalUnitsStr = yscaleStr;
    updateYAxisTitle(ntx);
end
