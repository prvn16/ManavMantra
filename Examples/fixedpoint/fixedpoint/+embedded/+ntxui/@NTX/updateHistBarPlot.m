function updateHistBarPlot(ntx)
% Update histogram bars based on current histogram data
% Updates bar heights, x-tick labels, and sign line on bars

%   Copyright 2010 The MathWorks, Inc.

% Create y-data for visualization of histogram bar as a patch
% Get bin counts for display
[posVal,negVal] = getBarData(ntx);

% Choose what to display in the histogram bars
% plot total (pos+neg) histogram
barVal = posVal+negVal;
N = numel(barVal);
yp = [zeros(1,N); barVal; barVal; zeros(1,N)];

% Create x-data
% No need to set cdata, since it gets overwritten in later call to
% updateBarThreshColor in this function.
axesVisible = get(ntx.hHistAxis,'Visible');
[xp,zp,xl,zl,cdata] = embedded.ntxui.NTX.createXBarData(ntx.BinEdges,ntx.HistBarWidth, ntx.HistBarOffset,ntx.ColorNormalBar);
set(ntx.hBar,'XData',xp,'YData',yp,'ZData',zp,'CData',cdata,'Visible',axesVisible);

% Sign line data
% Show Neg bin counts
%
% Use NaN's to separate line segments, then put into a column vector
yl = [negVal;negVal;nan(1,N)];
set(ntx.hlSignLine,'Visible',axesVisible, ...
    'XData',xl,'YData',yl(:),'ZData',zl);
