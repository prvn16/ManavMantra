function retObj = getHitObjectPlotSelect(hMode,evd,currObj)
% This undocumented function may be removed in a future release.
% 
% Copyright 2015-2017 The MathWorks, Inc.
% 
% 
% This function contains hittest buisness logic for Plot Edit mode.
% Plot Edit mode cannot always rely on the HitObject provided by the HG eventdata
% object. There are at least four cases where custom logic is reiqured to
% derive a different object to be processed by Plot Edit mode:
% 1. Brushing Primitives - are pickable with hittest on because they have context menu listeners attached, meaning that they
% will be picked up each time the user hits them with the mouse in Plot Edit mode. In this
% case we have to process the uderlying object (e.g charting line, bar ,
% area and ect), therefore we need to access the first pickable and
% selectable ancestor.
%
%2. Selection Handles (matlab.graphics.internal.SelectionHandles) - primitives of the object are pickable therefore they are reported by HG. In this case Plot Edit needs 
% to know what is the object that is surrounded by the Selection Handles in
% order to procees it, i.e. resize/change cursor.
%
%3. 3D axes -  The event data (evd) does not capture information about 3D axes when the 
% mouse is not over the plot box or the labels. In this case use a direct
% position calculation to determine if the mouse of is in this area
%
%4. self-contained Charts - the event data may reference implementation
%details of subclasses of matlab.graphics.chart.Chart. We make sure that
%clicks on the contents of a chart always select the chart, not internal
%objects/axes.
% 



hitObj = evd.HitObject;
selectedAxes = [];
retObj = [];

if isprop(evd,'HitPrimitive') && isequal(evd.HitObject,evd.HitPrimitive)
%     If the first ancestor with hittest on is the primitive itself, the
%     user may have hit a primitive brushing decoration. In this case,
%     return the first matlab.graphics.mixin.Selectable with HitTest on,
    selectableAncestor = ancestor(evd.HitPrimitive,'matlab.graphics.mixin.Selectable');
    if ~isempty(selectableAncestor)
        retObj = matlab.graphics.chart.internal.ChartHelpers.getPickableAncestor(selectableAncestor);
    else
%         If the primitive is part of Selection Handles return the
%         object surrounded by the Selection Handles
        selHandles = ancestor(hitObj,'matlab.graphics.internal.SelectionHandles');
        if ~isempty(selHandles)
            retObj = selHandles.TrueParent;
        end
    end
elseif isa(hitObj,'matlab.graphics.shape.internal.ScribePeer')
        % if a datatip is hit, return
        retObj = [];         
elseif isprop(evd,'HitPrimitive') && ~isempty(ancestor(evd.HitPrimitive,'matlab.graphics.chart.internal.SubplotPositionableChart'))
    %Chart supports innerposition (needed for plot-edit)
    retObj = ancestor(evd.HitPrimitive,'matlab.graphics.chart.internal.SubplotPositionableChart');
    
elseif isprop(evd,'HitPrimitive') && ~isempty(ancestor(evd.HitPrimitive,'matlab.graphics.chart.Chart'))
    %legacy chart without InnerPosition. Don't support selection yet.
    retObj = [];
else
    
%     Return any selected 3D axes that encompass the specified point.
%     This function is used to detect mouse events which occur inside 3d axes
%     but outside their plot box area
    
    if ~isempty(hitObj) && ishghandle(hitObj,'figure') || ...
            isa(hitObj,'matlab.ui.container.internal.UIContainer')
        point = evd.Point;
        for k=1:length(hMode.ModeStateData.SelectedObjects)
            if is3DAxes(hMode.ModeStateData.SelectedObjects(k))
                axesPos = getpixelposition(hMode.ModeStateData.SelectedObjects(k),true);
                if point(1)>=axesPos(1) && point(1)<=axesPos(1)+axesPos(3) && ...
                        point(2)>=axesPos(2) && point(2)<=axesPos(2)+axesPos(4)
                    selectedAxes = hMode.ModeStateData.SelectedObjects(k);
                    break
                end
            end
        end
        retObj = selectedAxes;
    end
    if ~isempty(currObj) && isempty(retObj)
%         If retObj is empty simply passthrough the currObj beacuse this
%         function could not detect 
        retObj = currObj;
    end
end






