function brushup(es,evd)

% This static method is called by the brush mode for windowButtonUpFcn
% events. This code may be modified in future releases.

%  Copyright 2008-2015 The MathWorks, Inc.

fig = es;
brushmode = getuimode(fig,'Exploration.Brushing');
selectionObject = brushmode.ModeStateData.SelectionObject;
if isempty(selectionObject)
    return
end
ax = selectionObject.Axes;

r = selectionObject.Graphics;
figSelectionType = get(fig,'SelectionType');

% If the selectionObject has an empty Graphics property then brushdrag
% was not called, and no drag gesture occurred. In this case, this is a
% click gesture and datamanager.brushRectangle should be called with
% clicked object and current figure pixel location as the selected
% region.
if isempty(r) && (strcmpi(figSelectionType,'normal') || ...
        strcmpi(figSelectionType,'extend'))
    % Find the clicked graphics object 
    hitobj = evd.HitObject;
 
    % If the first ancestor with hittest on is the primitive itself, the
    % user may have hit a primitive brushing decoration. In this case,
    % return the first matlab.graphics.mixin.Selectable with HitTest 'on'
    if isprop(evd,'HitPrimitive') && isequal(hitobj,evd.HitPrimitive)     
        selectableAncestor = ancestor(evd.HitPrimitive,'matlab.graphics.mixin.Selectable');
        if ~isempty(selectableAncestor)
            hitobj = matlab.graphics.chart.internal.ChartHelpers.getPickableAncestor(selectableAncestor);
        end
    end
    
    % Get current workspace for the initiator of the brush
    % Note that brushup is called by the mode object using hgeval.
    % This introduces 2 more stack layers
    [mfile,fcnname] = datamanager.getWorkspace(5);

    % Brush either the closest vertex on the clicked object or clear
    % the brushing if clicking on the axes background
    % Vertex picking is done in the
    % datamanager.brushRectangle method because it is analogous to
    % finding the interior vertices of a brushing polygon which is
    % also performed in the datamanager.brushRectangle by the
    % DataAnnotable::getEnclosedPoints() method
    bh = hggetbehavior(hitobj,'brush','-peek');
    excludedByBehaviorObject = ~isempty(bh) && ~bh.Enable;
    includedByBehaviorObject = ~isempty(bh) && bh.Enable;
    if includedByBehaviorObject || (isplotchild(hitobj) && ~excludedByBehaviorObject)
        currentFigPoint = hgconvertunits(fig,[get(fig,'CurrentPoint') 0 0],...
            get(fig,'Units'),'pixels',fig);
        datamanager.brushRectangle(ax,hitobj,...
                    hitobj,currentFigPoint(1:2),[],...
                    brushmode.ModeStateData.brushIndex,brushmode.ModeStateData.color,...
                    mfile,fcnname);
    elseif ishghandle(hitobj,'axes') && strcmp(get(fig,'SelectionType'),'normal')
        datamanager.brushRectangle(ax,brushmode.ModeStateData.brushObjects,...
                [],[],[],...
                brushmode.ModeStateData.brushIndex,brushmode.ModeStateData.color,...
                mfile,fcnname); 
    end
end

% Fire the mode accessor ActionPreCallback
brushmode.fireActionPostCallback(struct('Axes',ax));
    
% Clear selection ROI
selectionObject.reset;
brushmode.ModeStateData.lastRegion = [];
brushmode.ModeStateData.SelectionObject = [];

% Linked plots should resume updating linkedgraphics after a brush
linkMgr = datamanager.LinkplotManager.getInstance();
if length(linkMgr.Figures)>=1
    if brushmode.ModeStateData.LastLinkState
        linkMgr.setEnabled('on');
    else
        linkMgr.setEnabled('off');
    end
end

% Restore LegendColorbarListeners
if ~isempty(findprop(handle(ax),'LegendColorbarListeners'))
    res = get(ax,'LegendColorbarListeners');
    for k=1:min(length(brushmode.ModeStateData.LegendColorbarListenersState),length(res))
        res(k).Enabled = brushmode.ModeStateData.LegendColorbarListenersState{k}; 
    end
end