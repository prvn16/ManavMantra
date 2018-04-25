function tickCallback(hAx, xData, horizontal)
% Given a change to the "Horizontal" property, update the axes ticks
% appropriately

%   Copyright 2014-2017 The MathWorks, Inc.

if isempty(hAx) || strcmp(hAx.NextPlot, 'add')
    return;
end

% Set up the ticks on the axes:
if strcmp(horizontal,'on')
    yTickString = 'YTick';
    xTickString = 'XTickMode';
    if isprop(hAx,'ActiveYRuler')
        xData = ruler2num(xData, hAx.ActiveYRuler);
    end
else
    yTickString = 'XTick';
    xTickString = 'YTickMode';
    if isprop(hAx,'ActiveXRuler')
        xData = ruler2num(xData, hAx.ActiveXRuler);
    end
end
matlab.graphics.chart.primitive.bar.internal.updateTicks(hAx,xTickString,yTickString,xData);
