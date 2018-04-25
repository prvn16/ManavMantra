function tf = isplotyyaxes(ax)
% TF = ISPLOTYYAXES(AX) return true if AX is part of a plotyy chart

%   Copyright 2016 The MathWorks, Inc.

tf = false;
if isgraphics(ax)
    if isappdata(ax,'graphicsPlotyyPeer')
        plotyyAx = getappdata(ax,'graphicsPlotyyPeer');
        if ~isempty(plotyyAx) && ishandle(plotyyAx)
            tf = true;
        end
    end
end