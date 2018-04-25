function objs = getAllBrushableObjs(f)

% Obtain all the hg series as datamanager series objects together with
% their x,yDataSources for children of f
host = double(f);
if isappdata(host,'graphicsPlotyyPeer') 
    plotYYAxes = getappdata(host,'graphicsPlotyyPeer');
    if ishghandle(plotYYAxes)
        host = [host(:)',plotYYAxes];
    end
end
objs =  datamanager.getBrushableObjs(host);
