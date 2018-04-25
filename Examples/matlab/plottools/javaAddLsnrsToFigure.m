function javaAddLsnrsToFigure (fig, javaSelectionManager)
% This undocumented function may be removed in a future release.
  
% This is a utility function used by the plot tool.

% Copyright 2002-2014 The MathWorks, Inc.

% Get a handle to the PlotManager
plotmgr = feval(graph2dhelper('getplotmanager'));

% Create the PlotManager object-selection listener. TO DO: Remove the
% following conditions once hg objects use MCOS
model = graph2dhelper('findScribeLayer',fig);
selLsnr = event.listener (plotmgr, ...
	     'PlotSelectionChange', ...
         @(o, e)selectionLsnr(o, e, javaSelectionManager));

selobjects = getselectobjects(fig);
if ~isactiveuimode(fig,'Standard.EditPlot') && isempty(selobjects)
    selectionLsnr([],struct('SelectedObjects',fig,'Figure',fig),javaSelectionManager);
else
    selectionLsnr([],struct('SelectedObjects',selobjects,'Figure',fig),...
        javaSelectionManager);
end

% Second, create the PlotDone listener:
plotDoneLsnr = event.listener (plotmgr, ...
         'PlotFunctionDone', ...
         @(o,e)figPlotDoneCallback(o, e, javaSelectionManager));

% Third, guarantee that the event handlers will not pass out of scope
% and be garbage-collected:
selPropName = 'SelectionMgrScribeSel';
if ~isprop(handle(fig), selPropName)
    p = addprop(fig,selPropName);
    p.Transient = true;
    p.Hidden = true;
end
set (handle(fig), selPropName, selLsnr);

plotDonePropName = 'SelectionMgrPlotDone';
if ~isprop (handle(fig), plotDonePropName)
    p = addprop(fig,plotDonePropName);
    p.Transient = true;
    p.Hidden = true;
end
set (handle(fig), plotDonePropName, plotDoneLsnr);


%-------------------------------
function selectionLsnr(hProp, eventData, javaSelectionManager) %#ok<INUSL>

% If the selection has occurred on a figure which is not docked in the Plot
% Tools, no action should be taken.
if ~isequal(handle(eventData.Figure),handle(javaSelectionManager.getFigureHandle))
    return
end
tmp = eventData.SelectedObjects;

% Remove invalid handles
ind = ~ishghandle(tmp);
tmp(ind) = [];

% Create an array of custom Property Panel UDD objects
customPanelObjs = cell(length(tmp),1);
customPanelsExist = false;

for i = 1:length(tmp)
    % Register any custom Property Panels
    behavePlotEdit = hggetbehavior(tmp(i),'PlotTools','-peek');
    if ~isempty(behavePlotEdit) && ~isempty(behavePlotEdit.PropEditPanelObject)
        com.mathworks.page.plottool.PropertyEditor.registerGraphicsToPropPanel(...
            behavePlotEdit.PropEditPanelJavaClass,strrep(class(behavePlotEdit.PropEditPanelObject),'.','_'));
        customPanelObjs{i} = java(behavePlotEdit.PropEditPanelObject);
        customPanelsExist = true;
    end
end

objs = javaGetHandles (tmp);
if customPanelsExist
    javaSelectionManager.onScribeSelectionChanged(objs,customPanelObjs);
else
    javaSelectionManager.onScribeSelectionChanged(objs);
end

%-------------------------------
function figPlotDoneCallback (~, eventData,javaSelectionManager)

if ~isequal(handle(eventData.Figure),handle(javaSelectionManager.getFigureHandle))
    return
end
ac = javaSelectionManager.getFigureCanvas;
awtinvoke(ac, 'requestFocus()');
