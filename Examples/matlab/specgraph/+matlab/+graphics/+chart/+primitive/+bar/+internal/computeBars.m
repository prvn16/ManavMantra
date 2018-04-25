function [xOffset,yOffset,widthScaleFactor] = computeBars(x,y,isGrouped,maxSpacing)

%   Copyright 2014-2016 The MathWorks, Inc.

% Determine the number of bars and series
[numBars,numSeries] = size(y);

% Calculate the Y-offset:
yOffset = [];
if ~isGrouped && (numSeries>1)
    % replace nan with 0 for use in cumsum
    y(~isfinite(y))=0;
    ySum = cumsum(y,2);
    yOffset = [zeros(numBars,1),ySum(:,1:end-1)];
end

% Determine the width of each bar:
groupWidth = 0.8;
if numSeries == 1 || ~isGrouped
    groupWidth = 1;
else
    groupWidth = min(groupWidth,numSeries/(numSeries+1.5));
end

% Figure out the spacing between bars
barSpacing = min(diff(unique(x)));
if isempty(barSpacing) || ~isfinite(barSpacing)
    barSpacing = 1;
end
barSpacing = min(barSpacing, maxSpacing);

if isGrouped && (numSeries>1)
    widthScaleFactor = repmat(groupWidth/numSeries,1,numSeries).*barSpacing;
    dt = (0:(numSeries-1))-(numSeries-1)/2;
    xOffset = dt.*widthScaleFactor;
else
    % There is no offset for stacked bar plots or when numSeries == 1
    widthScaleFactor = ones(1,numSeries).*barSpacing;
    xOffset = zeros(1,numSeries);
end

end
