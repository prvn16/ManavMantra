function brushdrag(es,ed)
% Brush mode WindowMouseMotion callback

%  Copyright 2007-2015 The MathWorks, Inc.


fig = double(es);

% Hittest needs current point units to be the figure units when the motion
% callback is triggered from a mode
propName = 'Point';
curr_units = ed.(propName);
set(fig,'CurrentPoint',curr_units);

% Get the hit axes
axall = ancestor(ed.HitObject, 'axes');

% Restrict hit axes to those with 'HandleVisibility','on'
if ~isempty(axall)
   axall = findobj(axall,'flat','type','axes','HandleVisibility','on');
end
% and remove axes with brush behavior off
if ~isempty(axall)
    off = arrayfun(@datamanager.isBrushBehaviorOff,axall);
    axall(off) = [];
end

% Get objects
brushmode = getuimode(fig,'Exploration.Brushing');
selectionObject = brushmode.ModeStateData.SelectionObject;
if isempty(selectionObject) || isempty(selectionObject.ScribeStartPoint) ...
        || length(selectionObject.ScribeStartPoint)<2
    if ~isempty(axall) 
        setptr(fig,'crosshair');
    else
        setptr(fig,'arrow');
    end
    return
end
ax = selectionObject.Axes;

% If the start axes disagrees with the initial axes quick return
if ~isempty(axall) && ~any(axall==ax)
    setptr(fig,'arrow');
    return
end
setptr(fig,'crosshair');
brushIndex = brushmode.ModeStateData.brushIndex;

% Get current workspace for the initiator of the brush. The number "5" 
% reflects the stack depth of the calling workspace.
[mfile,fcnname] = datamanager.getWorkspace(5);

% Draw the ROI and get the ROI polygon/ROI dimensions
region = brushmode.ModeStateData.SelectionObject.draw(ed);
drawnow('expose');

% Brush points inside the ROI
datamanager.brushRectangle(ax,brushmode.ModeStateData.brushObjects,...
    [],region,brushmode.ModeStateData.lastRegion,...
    brushIndex,brushmode.ModeStateData.color,mfile,fcnname);
brushmode.ModeStateData.lastRegion = region;

% Brush data in the companion axes for plotyy
if ~isempty(brushmode.ModeStateData.plotYYModeStateData)
    axYY = brushmode.ModeStateData.plotYYModeStateData.currentAxes;
    rectPosYY = region;
    datamanager.brushRectangle(axYY,brushmode.ModeStateData.plotYYModeStateData.brushObjects,...
        [],rectPosYY,brushmode.ModeStateData.plotYYModeStateData.lastRegion,...
        brushIndex,brushmode.ModeStateData.color,mfile,fcnname);
    brushmode.ModeStateData.plotYYModeStateData.lastRegion = rectPosYY;
end
