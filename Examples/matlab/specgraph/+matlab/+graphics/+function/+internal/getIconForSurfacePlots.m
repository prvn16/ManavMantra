function graphic = getIconForSurfacePlots(hObj, varargin)

%   Copyright 2015-2017 The MathWorks, Inc.

graphic=matlab.graphics.primitive.world.Group;

% the area
if ~strcmp(hObj.FaceColor, 'none')
    iconFace = matlab.graphics.primitive.world.Quadrilateral;
    iconFace.Parent = graphic;
    iconFace.VertexData = single([0 1 1 0; 0 0 1 1; 0 0 0 0]);
    % iconFace.StripData = uint32([1 5]);

    if isequal(hObj.FaceColor,'flat') || isequal(hObj.FaceColor,'interp')
        if strcmp(hObj.Faces.ColorBinding, 'none')
            iconFace.Visible='off';
        else
            iconFace.ColorBinding='interpolated';
            iconFace.ColorData=single([0 0 1 1]);
            iconFace.ColorType='colormapped';
            iconFace.Texture=hObj.Faces.Texture;
        end
    else
        hgfilter('RGBAColorToGeometryPrimitive', iconFace, hObj.FaceColor);
    end
end

% the edge
if ~strcmp(hObj.LineStyle,'none')
    iconEdge = matlab.graphics.primitive.world.LineStrip;
    iconEdge.Parent = graphic;
    iconEdge.VertexData = single([0 1 .5 .5;.5 .5 0 1;0 0 0 0]);
    iconEdge.StripData = uint32([1 3 5]);

    if isequal(hObj.EdgeColor,'flat') || isequal(hObj.EdgeColor,'interp')
        if strcmp(hObj.Edge.ColorBinding, 'none')
            iconEdge.Visible='off';
        else
            iconEdge.ColorBinding='interpolated';
            iconEdge.ColorData=single([0.5 0.5 0 1]);
            iconEdge.ColorType='colormapped';
            iconEdge.Texture=hObj.Edge.Texture;
        end
    else
        hgfilter('RGBAColorToGeometryPrimitive', iconEdge, hObj.EdgeColor);
    end

    % edge LineStyle
    hgfilter('LineStyleToPrimLineStyle', iconEdge, hObj.LineStyle);
    
    % line width
    iconEdge.LineWidth = hObj.LineWidth;
end

% the marker
if ~strcmp(hObj.Marker,'none')
    iconMarker = matlab.graphics.primitive.world.Marker;
    iconMarker.Parent = graphic;
    iconMarker.VertexData = single([.5;.5;0]);
    
    % marker
    hgfilter('MarkerStyleToPrimMarkerStyle', iconMarker, hObj.Marker);
    
    % marker size
    iconMarker.Size = hObj.MarkerSize;
    
    % marker line width
    iconMarker.LineWidth = hObj.LineWidth;
    
    % marker edge color
    mec = hObj.MarkerEdgeColor;
    if strcmpi(mec,'auto')
        mec = hObj.FaceColor;
    end
    hgfilter('EdgeColorToMarkerPrimitive',iconMarker,mec);

    % marker face color
    mfc = hObj.MarkerFaceColor;
    if strcmpi(mfc,'auto')
        mfc = mec;
    end
    hgfilter('FaceColorToMarkerPrimitive',iconMarker,mfc);
end
