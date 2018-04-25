function objs=getselectobjects(fig)
%GETSELECTOBJECTS Returns selected objects.

%   H=GETSELECTOBJECTS(FIG) returns a vector H of handles to selected 
%   objects in the figure FIG.
%   H=GETSELECTOBJECTS returns a vector H of handles to selected 
%   objects in the current figure
%
%   See also DESELECTALL, SELECTOBJECT.
%
%   Copyright 1984-2009 The MathWorks, Inc.
%   $  $  $  $

narginchk(1,1);

if ~ishghandle(fig,'figure')
    error(message('MATLAB:getselectobjects:invalidargument'));
end

% Since this may be called from outside the mode, obtain the mode for the
% given figure handle.
hMan = uigetmodemanager(fig);
hCurrMode = hMan.CurrentMode;
hPlotEdit = [];
if ~isempty(hCurrMode)
    hPlotEdit = hCurrMode.getuimode('Standard.EditPlot');
end
if isempty(hPlotEdit)
    hPlotEdit = plotedit(fig,'getmode');
end
hMode = hPlotEdit.ModeStateData.PlotSelectMode;

% Make sure we have valid handles to deal with. Otherwise, explosions may
% occur
localFixSelectedObjs(hMode);

% Return the objects:
objs = hMode.ModeStateData.SelectedObjects';

%--------------------------------------------------------------------%
function localFixSelectedObjs(hMode)

% remove invalid handles from slectobjs list
hMode.ModeStateData.SelectedObjects(~ishghandle(hMode.ModeStateData.SelectedObjects)) = [];