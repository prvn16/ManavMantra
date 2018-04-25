function figRegionCoords = draw(this,varargin)
% This internal helper function may change in a future release.

% DRAW returns the geometry of the cross section:
%
% DRAW returns the geometry of the cross section in axes data coordinates
% and draws the brushing corresponding brushing rectangle in the scribe
% layer after clipping it to the axes bounds. Current figure mouse position
% is determined from the eventData or the figure 'CurrentPoint' property,
% current axes data mouse position is determined from the axes
% 'CurrentPoint' property.

%  Copyright 2008-2014 The MathWorks, Inc.

% Get ROI vertices in figure coords
fig = this.Figure;
ax = this.Axes;

% Update the AxesYLim because the active dataspace may be different than the
% cached one
this.AxesYLim = ax.YAxis(ax.ActiveDataSpaceIndex).Limits;

dataDragEnd = get(ax,'CurrentPoint');
dataDragStart = this.AxesStartPoint;

% Clip the ROI to the axes limits in data space.
xlim = this.AxesXLim;
ylim = this.AxesYLim;
dataDragEnd(:,1) = min(max(dataDragEnd(:,1),xlim(1)),xlim(2));
dataDragEnd(:,2) = min(max(dataDragEnd(:,2),ylim(1)),ylim(2));
dataDragStart(:,1) = min(max(dataDragStart(:,1),xlim(1)),xlim(2));
dataDragStart(:,2) = min(max(dataDragStart(:,2),ylim(1)),ylim(2));

% Get the camera coordinates for the brushing ROI.
dataStart = dataDragStart(1,1:2);
dataEnd = dataDragEnd(1,1:2);
segment1 = localTransform2DDataLineToCameraCoords(ax,[dataStart(1) dataStart(2)],...
                 [dataEnd(1) dataStart(2)]);
segment2 = localTransform2DDataLineToCameraCoords(ax,[dataEnd(1) dataStart(2)],...
                 [dataEnd(1) dataEnd(2)]);
segment3 = localTransform2DDataLineToCameraCoords(ax,[dataEnd(1) dataEnd(2)],...
                 [dataStart(1) dataEnd(2)]);
segment4 = localTransform2DDataLineToCameraCoords(ax,[dataStart(1) dataEnd(2)],...
                 [dataStart(1) dataStart(2)]);
% Remove overlapping line segment start and end points             
camRegionCoords = [segment1,...
                   segment2(:,2:end),...
                   segment3(:,2:end),...
                   segment4(:,2:end-1)];  



% Get figure coordinates of brushing ROI for drawing ROI
% into the overlay camera in normalized figure units.
figRegionCoords = brushing.select.transformCameraToFigCoord(ax,camRegionCoords);

% If the height or width of the ROI is less than than delta (aprox. 0.05% of the default axes size) ,
% then select nothing and hide the ROI tool.
delta = 3;
h = abs(figRegionCoords(1,1) - figRegionCoords(1,2)); %ROI height
w = abs(figRegionCoords(2,1) - figRegionCoords(2,4)); %ROI width

if  h < delta || w < delta
   if ~isempty(this.Graphics) && isvalid(this.Graphics) && strcmp(this.Graphics.Visible,'on')
       this.Graphics.Visible = 'off';
   end
   
   % Return 4 vertices at the same point. This avoids calling TransformLine
   % on a zero length line. 
   iter = matlab.graphics.axis.dataspace.XYZPointsIterator;
   iter.XData = dataDragStart(1,1);
   iter.YData = dataDragStart(1,2);
   iter.ZData = dataDragStart(1,3);
   camRegionCoords = TransformPoints(ax.DataSpace,[],iter);
   figRegionCoords = repmat(brushing.select.transformCameraToFigCoord(ax,camRegionCoords),[1 4]);
   return

end


vertexData = zeros([3 size(camRegionCoords,2)]);
panelRegionCoords = figRegionCoords;
hasPanelParent = isa(ax.Parent,'matlab.ui.container.Container') && ~ isa(ax.Parent,'matlab.ui.Figure');
if hasPanelParent
    uipanelpos = getpixelposition(ax.Parent,true);
end
    
% Convert to normalized units of the axes parent
for k=1:size(figRegionCoords,2)  
    if hasPanelParent
        panelRegionCoords(:,k) = figRegionCoords(:,k)-uipanelpos(1:2)';
        tmp = hgconvertunits(fig,[panelRegionCoords(:,k)' 0 0],'pixels','normalized',ax.Parent);
        vertexData(1:2,k) = tmp(1:2);
    else
        tmp = hgconvertunits(fig,[figRegionCoords(:,k)' 0 0],'pixels','normalized',fig);
        vertexData(1:2,k) = tmp(1:2);
    end
    
end
vertexData(1:2,end+1) = vertexData(1:2,1);              

% Position the text at xMin, yMin of the ROI
textPosition = single([min(vertexData(1:2,:),[],2);0]);


% if the rulers are non numeric, show the corresponding values in the ROI
[xStart,yStart] = matlab.graphics.internal.makeNonNumeric(ax,dataDragStart(1,1),dataDragStart(1,2));
[xEnd,yEnd] = matlab.graphics.internal.makeNonNumeric(ax,dataDragEnd(1,1),dataDragEnd(1,2));

regionStrX = formatRegionData(xStart,xEnd,'X');
regionStrY = formatRegionData(yStart,yEnd,'Y');

regionStr  = {regionStrY;regionStrX};

if isempty(this.Graphics)
    if isvalid(this.ScribeLayer)
        % Create the brushing ROI rectangle
        this.Graphics = matlab.graphics.primitive.world.LineStrip('parent',this.ScribeLayer);
        set(this.Graphics,'ColorData',uint8([255;0;0;255]),...
            'ColorBinding','object',...
            'HandleVisibility','off',...
            'Hittest','off',...
            'PickableParts','none',...
            'LineWidth',0.5,'VertexData',single(vertexData),'StripData',uint32([1 size(vertexData,2)+1]));
        
        % Create the text
        this.Text = matlab.graphics.primitive.world.Text('parent',this.ScribeLayer,'VertexData',textPosition,'String',regionStr);
        fontObj = this.Text.Font;
        fontObj.Size = 9;
        fontObj.Name = get(groot,'defaultUIcontrolFontName');
        set(this.Text,'Font',fontObj);
    end
else
    % Update the existing graphics
    set(this.Graphics,'VertexData',single(vertexData),'StripData',uint32([1 size(vertexData,2)+1]),'Visible','on');
    set(this.Text,'VertexData',textPosition,'String',regionStr,'VerticalAlignment','top');
end

function output = formatRegionData(startPoint,endPoint,coordLabel)
if ~isnumeric(startPoint)
    startPoint = char(startPoint);
    endPoint = char(endPoint);
    output = sprintf('%s: %s to %s',coordLabel,startPoint,endPoint); 
else
    output = sprintf('%s: %0.3g to %0.3g',coordLabel,startPoint, endPoint);    
end



function lineCameraVertices = localTransform2DDataLineToCameraCoords(ax,x1,x2)

lineDataCoords  = [x1(1) x2(1);x1(2) x2(2); 0 0];
lineCameraVertices = TransformLine(ax.DataSpace,[],lineDataCoords');

