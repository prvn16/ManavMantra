function axList = vectorizePlotyyAxes(hAx)
% Given an axes, return a vector representing any plotyy-dependent axes.
% Note: This code is implementation-specific and meant as a place-holder
% against the time when we have multiple data-spaces in one axes.

%   Copyright 2014-2015 The MathWorks, Inc.

axList = hAx;
if ~isempty(axList)
    if isappdata(hAx,'graphicsPlotyyPeer')
        newAx = getappdata(hAx,'graphicsPlotyyPeer');
        if ishghandle(newAx)
            axList = [axList;newAx];
        end
    end
end