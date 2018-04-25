function graphic = getIconForLinePlots(hObj, varargin)

%   Copyright 2013-2017 The MathWorks, Inc.

% Example
%   Stair wants a standard line icon with a marker in the middle
%   gr = getLegendGraphic(hObj);
%
%   Stem wants a lollipop looking icon
%   gr = getLegendGraphic(hObj, single([0 .7;.5 .5;0 0]), single([.7;.5;0]));

if nargin == 1
    edgeVertexData = single([0 1;.5 .5;0 0]);
    markerVertexData = single([.5;.5;0]);
elseif nargin == 3
    edgeVertexData = varargin{1};
    markerVertexData = varargin{2};
end

graphic=matlab.graphics.primitive.world.Group;

% the edge
if ~strcmp(hObj.LineStyle,'none')
    iconEdge = matlab.graphics.primitive.world.LineStrip;
    iconEdge.Parent = graphic;
    iconEdge.VertexData = edgeVertexData;
    iconEdge.StripData = uint32([1 3]);

    % edge color
    hgfilter('RGBAColorToGeometryPrimitive', iconEdge, hObj.Color_I);

    % edge LineStyle
    hgfilter('LineStyleToPrimLineStyle', iconEdge, hObj.LineStyle_I);
    
    % line width
    iconEdge.LineWidth = hObj.LineWidth;
end

% the marker
if ~strcmp(hObj.Marker,'none')
    iconMarker = matlab.graphics.primitive.world.Marker;
    iconMarker.Parent = graphic;
    iconMarker.VertexData = markerVertexData;
    
    % marker
    hgfilter('MarkerStyleToPrimMarkerStyle', iconMarker, hObj.Marker_I);
    
    % marker size
    iconMarker.Size = hObj.MarkerSize;
    
    % marker line width
    iconMarker.LineWidth = hObj.LineWidth;
    
    % marker edge color
    mec = hObj.MarkerEdgeColor_I;
    if strcmpi(mec,'auto')
        mec = hObj.Color_I;
    end
    hgfilter('EdgeColorToMarkerPrimitive',iconMarker,mec);

    % marker face color
    mfc = hObj.MarkerFaceColor_I;
    if strcmpi(mfc,'auto')
        mfc = mec;
    end
    hgfilter('FaceColorToMarkerPrimitive',iconMarker,mfc);
end
