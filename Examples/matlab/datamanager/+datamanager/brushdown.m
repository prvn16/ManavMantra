function brushdown(es,evd)

% This static method is called by the brush mode for windowButtonDownFcn
% events. This code may be modified in future releases.

%  Copyright 2007-2015 The MathWorks, Inc.


% Ignore right clicks in axes
fig = es;
if strcmp(get(fig,'SelectionType'),'alt')
    return
end
 
% Linked plots should not update linked graphics during a brush to save time
linkMgr = datamanager.LinkplotManager.getInstance();
lastLinkState = linkMgr.LinkListener.isEnabled;
linkMgr.setEnabled('off');

% Get the hit axes
ax = localHittest(fig,evd,'axes');
if ~isempty(ax)
    ax = findobj(ax,'flat','type','axes','HandleVisibility','on',...
        '-not','Tag','legend','-not','Tag','Colorbar');
end
plotYYAxes = [];
if ~isempty(ax)
    % For plotyy take the opaque axes
    if length(ax)>1
        ind = 1;
        for k=1:length(ax)
            if isnumeric(get(ax(k),'Color')) && ~isequal(get(ax(k),'Color'),[0 0 0])
                ind = k;
                break;
            end
        end
        ax = ax(ind);
    end
    
    % Get the mode and create a brushing.select object to capture the ROI
    brushmode = getuimode(fig,'Exploration.Brushing');
    
    % If the previous ROI graphics is still visible then clear it. This
    % can happen if the mouse up event occurred outside MATLAB, e.g.,
    % because the mouse button was released after giving focus to a
    % non-MATLAB process. See g608428.
    if ~isempty(brushmode.ModeStateData.SelectionObject) && ...
            isvalid(brushmode.ModeStateData.SelectionObject)
       brushmode.ModeStateData.SelectionObject.reset;
    end

    if ~is2D(ax) 
        brushmode.ModeStateData.SelectionObject = brushing.select3d(ax);
    else
        brushmode.ModeStateData.SelectionObject = brushing.select2d(ax);
    end
    
    % Fire the mode accessor ActionPreCallback
    brushmode.fireActionPreCallback(struct('Axes',ax));

    brushmode.ModeStateData.LastLinkState = lastLinkState;
    extendMode = strcmpi(get(fig,'SelectionType'),'extend');    
    
    % If the axes is part of a plotyy, create a ModeStateData to represent
    % the brushing of the peer axes.
    if isappdata(ax,'graphicsPlotyyPeer')
         plotYYAxes = getappdata(ax,'graphicsPlotyyPeer');   
         % If the plotyy double axes have been replaced the
         % graphicsPlotyypeer axes is present but invalid. Act like the
         % axes is empty in this case (g589646)
         if ishghandle(plotYYAxes)
            brushmode.ModeStateData.plotYYModeStateData = brushmode.ModeStateData;
            brushmode.ModeStateData.plotYYModeStateData.currentAxes = plotYYAxes;
         else
            brushmode.ModeStateData.plotYYModeStateData = [];
            plotYYAxes = [];
         end
    else
        brushmode.ModeStateData.plotYYModeStateData = [];
    end
else
    return
end

% Record brushable objects in the current axes
brushmode.ModeStateData.brushObjects = datamanager.getBrushableObjs(ax);
if ~isempty(plotYYAxes)
    brushmode.ModeStateData.plotYYModeStateData.brushObjects = ...
        datamanager.getBrushableObjs(plotYYAxes);
end

% Cache axes limit modes and set them to manual so that the axes limits
% do not change during the brushing gesture
if ~isempty(plotYYAxes) % No axes limit caching needed for MCOS graphics 
    % Record the starting point for the ROI gesture
    brushmode.ModeStateData.plotYYModeStateData.startPoint = get(plotYYAxes,'CurrentPoint');
    brushmode.ModeStateData.plotYYModeStateData.scribeStartPoint = ...
         brushmode.ModeStateData.SelectionObject.ScribeStartPoint;
end
% The FaceOffsetFactor and FaceOffsetBias used in SurfaceBrushingImpl
% are ignored when using painters. This can cause rendering problems
% due to quad brushing primitives sharing the same vertexdata as the
% underlying surface (g654092). For now switch to opengl in this case.
if strcmp(fig.Renderer,'painters') && ~isempty(findobj(gca,'type','surface'))
    fig.Renderer = 'openGL';
end

% If necessary rebuild the graphics cache
brushMgr = datamanager.BrushManager.getInstance();
if ~isempty(linkMgr.Figures)
    Ifig = find(double([linkMgr.Figures.('Figure')])==double(fig));
    if ~isempty(Ifig)
        [mfile,fcnname] = datamanager.getWorkspace(5);
        if linkMgr.Figures(Ifig).Dirty       
            linkMgr.updateLinkedGraphics(Ifig);
        end
        % If we are in extend mode - restrict the columns of the brushing arrays of
        % variables in this axes to include only these graphics.   
        if extendMode           
            brushMgr.alignRows(linkMgr.Figures(Ifig),ax,mfile,fcnname);
        else
            brushMgr.clearLinked(Ifig,ax,mfile,fcnname);
        end
        if ~isempty(plotYYAxes)
            if extendMode           
                brushMgr.alignRows(linkMgr.Figures(Ifig),plotYYAxes,mfile,fcnname);
            else
                brushMgr.clearLinked(Ifig,plotYYAxes,mfile,fcnname);
            end
        end
    end
end
if ~extendMode    
    brushMgr.clearUnlinked(ax,brushmode.ModeStateData.brushObjects);
    if ~isempty(plotYYAxes)
        brushMgr.clearUnlinked(plotYYAxes,brushmode.ModeStateData.plotYYModeStateData.brushObjects);
    end
end

% Cache the brushing color index
brushColor = brushmode.ModeStateData.color;
brushStyleMap =  matlab.graphics.chart.primitive.brushingUtils.getBrushStyleMap(es);
brushIndex = find(all(ones(size(brushStyleMap,1),1)*brushColor==brushStyleMap,2));
if isempty(brushIndex)
    brushStyleMap = [brushStyleMap; brushColor];
    brushIndex = size(brushStyleMap,1);
    set(es,'BrushStyleMap',brushStyleMap)
end
brushmode.ModeStateData.brushIndex = brushIndex;

% Turn off LegendColorbarListeners to prevent attempts to re-layout the
% figure during a brush
if ~isempty(findprop(handle(ax),'LegendColorbarListeners'))
    res = get(ax,'LegendColorbarListeners');
    if ~isempty(res)
        if isa(res(1), 'handle.listener')
            brushmode.ModeStateData.LegendColorbarListenersState = get(res,{'Enabled'}); 
            set(res,'Enabled','off');
        else
            for k=1:length(res)
                brushmode.ModeStateData.LegendColorbarListenersState{k} = res(k).Enabled;
                res(k).Enabled = false;
            end
        end          
    else
        brushmode.ModeStateData.LegendColorbarListenersState = [];
    end
else
    brushmode.ModeStateData.LegendColorbarListenersState = [];
end
if ~isempty(plotYYAxes)
    if ~isempty(findprop(handle(plotYYAxes),'LegendColorbarListeners'))
        res = get(plotYYAxes,'LegendColorbarListeners');
        if ~isempty(res)
            if isa(res(1), 'handle.listener')
                brushmode.ModeStateData.plotYYModeStateData.LegendColorbarListenersState = ...
                    get(res,{'Enabled'}); 
                set(res,'Enabled','off');
            else
                for k=1:length(res)
                    brushmode.ModeStateData.plotYYModeStateData.LegendColorbarListenersState = ...
                       res(k).Enabled;
                    res(k).Enabled = false;
                end
            end
        end
    else
        brushmode.ModeStateData.plotYYModeStateData.LegendColorbarListenersState = [];
    end
end


function obj = localHittest(hFig,evd,varargin)
% For eventData generated by a sceneViewer, the Primitive will be empty
% if the click is outside the axes camera area but inside the axes
% rectangular hull. Since it makes sense to initiate a brush gesture
% from this region for 3d rotated axes we need to detect the 
% corresponding axes when this occurs.
if ~isempty(evd.HitPrimitive)
    obj = ancestor(evd.HitObject, 'axes');
else
    ax =  findobj(hFig,'type','axes','-not','Tag','legend','-not','Tag','Colorbar');
    obj = [];
    for k=1:length(ax)
        axesPos = getpixelposition(ax(k),true);
        if axesPos(1)<=evd.Point(1) && axesPos(1)+axesPos(3)>=evd.Point(1) && ...
                axesPos(2)<=evd.Point(2) && axesPos(2)+axesPos(4)>=evd.Point(2)
            obj = ax(k);
            break;
        end
    end
end
if ~isempty(obj)
    off = arrayfun(@datamanager.isBrushBehaviorOff,obj);
    obj(off) = [];
end
