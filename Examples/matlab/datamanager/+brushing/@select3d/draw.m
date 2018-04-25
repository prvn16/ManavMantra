function figRegionCoords = draw(this,varargin)
% This internal helper function may change in a future release.

% DRAW draws a region of interest (ROI) based on a brushing drag gesture.
%
% DRAW returns the geometry of the cross section as a 2x2 matrix where 
% each row represents the pair of coordinates in figure normalized units.
% Note that unlike 2d data brushing, 3d data brushing uses the figure
% coordinates rather than the axes coordinates to take advantage of the hg
% projection functionality. Note that the ROI will be clipped to the axes
% bounds.

%  Copyright 2008-2014 The MathWorks, Inc.
   
fig = this.Figure;
ax = this.Axes;

% It is possible for windowFocusLostFcn to clear the brushing.select3d 
% object when the renderer is changed to openGL by the brushdown function
% during a brushing gesture (g654964). This will cause the Axes and Figure
% properties to be cleared. Quick return to prevent that causing an error.
if isempty(ax) || isempty(fig)
    figRegionCoords =  [];
    return
end 

% Get ROI vertices in figure coords
figDragEnd = get(fig,'CurrentPoint');
figDragStart = this.ScribeStartPoint;

%Since all coputations are done in pixels , make sure that the units are
%consistent 
figDragEnd = hgconvertunits(fig,[figDragEnd 0 0],fig.Units,'pixels',fig);
figDragStart = hgconvertunits(fig,[figDragStart 0 0],fig.Units,'pixels',fig);


% Find the cubic hull of the axes vertices

xlim = this.AxesXLim;
ylim = this.AxesYLim;
zlim = this.AxesZLim;

iter = matlab.graphics.axis.dataspace.XYZPointsIterator;
iter.XData = [xlim(1) xlim(2) xlim(2) xlim(1) xlim(1) xlim(2) xlim(2) xlim(1)];
iter.YData = [ylim(1) ylim(1) ylim(1) ylim(1) ylim(2) ylim(2) ylim(2) ylim(2)];
iter.ZData = [zlim(1) zlim(1) zlim(2) zlim(2) zlim(1) zlim(1) zlim(2) zlim(2)];
camAxesVertices = TransformPoints(ax.DataSpace,[],iter);
figAxesVertices = brushing.select.transformCameraToFigCoord(ax,camAxesVertices);
minX = min(figAxesVertices(1,:));
maxX = max(figAxesVertices(1,:));
minY = min(figAxesVertices(2,:));
maxY = max(figAxesVertices(2,:));

% Clip ROI in figure space to axes vertices
figDragEnd(1) = max(min(figDragEnd(1),maxX),minX);
figDragEnd(2) = max(min(figDragEnd(2),maxY),minY);
figDragStart(1) = max(min(figDragStart(1),maxX),minX);
figDragStart(2) = max(min(figDragStart(2),maxY),minY);
figRegionCoords = [figDragStart(1) figDragStart(2);...
                   figDragEnd(1) figDragStart(2);...
                   figDragEnd(1) figDragEnd(2);...
                   figDragStart(1) figDragEnd(2);...
                   figDragStart(1) figDragStart(2)]';
% If the height or width of the ROI is less than 0.5% of the axes limits,
% then select nothing and hide the ROI tool.
if abs(figDragEnd(1)-figDragStart(1))<0.005*(maxX-minX) || ...
    abs(figDragEnd(2)-figDragStart(2))<0.005*(maxY-minY)
   if ~isempty(this.Graphics) && isvalid(this.Graphics) && strcmp(this.Graphics.Visible,'on')
       this.Graphics.Visible = 'off';
   end
   return
end 

% Get figure coordinates of brushing ROI for drawing ROI
% into the overlay camera in normalized figure units.
vertexData = zeros([3 size(figRegionCoords,2)]);
panelRegionCoords = figRegionCoords;
for k=1:size(figRegionCoords,2)
    if isa(ax.Parent,'matlab.ui.container.Container') && ~isa(ax.Parent,'matlab.ui.Figure')
        uipanelpos = getpixelposition(ax.Parent,true);
        panelRegionCoords(:,k) = figRegionCoords(:,k)-uipanelpos(1:2)';
        tmp = hgconvertunits(fig,[panelRegionCoords(:,k)' 0 0],'pixels','normalized',ax.Parent);
        vertexData(1:2,k) = tmp(1:2);
    else
        tmp = hgconvertunits(fig,[figRegionCoords(:,k)' 0 0],'pixels','normalized',fig);
        vertexData(1:2,k) = tmp(1:2);
    end
end
               
r = this.Graphics;
if isempty(r)
    if isvalid(this.ScribeLayer)
        this.Graphics = matlab.graphics.primitive.world.LineStrip('parent',this.ScribeLayer);
        set(this.Graphics,'ColorData',uint8([255;0;0;255]),...
          'ColorBinding','object',...
          'HandleVisibility','off',...
          'Hittest','off',...
          'PickableParts','none',...
          'LineWidth',0.5,'VertexData',single(vertexData),'StripData',uint32([1 size(vertexData,2)+1]));
    end
else
    set(this.Graphics,'VertexData',single(vertexData),'StripData',uint32([1 size(vertexData,2)+1]),'Visible','on');
end
