function setPrimitiveColors(updateState, hPrim, numBars, color, cdata, cdatashape, alpha)

%   Copyright 2017 The MathWorks, Inc.

import matlab.graphics.chart.primitive.utilities.CDataShape

hColorIter = matlab.graphics.axis.colorspace.IndexColorsIterator;
if strcmp(color,'flat')
    hColorIter.Colors = cdata;
    hColorIter.CDataMapping = 'scaled';
    hColorIter.Indices = repmat(1:numBars,4,1);
    if cdatashape.isColorMappedScalar || cdatashape.isColorMapped
        % Use a color iterator to get the actual color.
        actualColor = updateState.ColorSpace.TransformColormappedToTrueColor(hColorIter);
        if ~isempty(actualColor)
            hPrim.ColorData_I = actualColor.Data;
            hPrim.ColorType_I = actualColor.Type;
            hPrim.ColorBinding_I = 'interpolated';
        else % empty colormap
            hPrim.ColorBinding_I = 'none';
        end
    elseif cdatashape.isTrueColor
        actualColor = updateState.ColorSpace.TransformTrueColorToTrueColor(hColorIter);
        hPrim.ColorData_I = actualColor.Data;
        hPrim.ColorType_I = actualColor.Type;
        hPrim.ColorBinding_I = 'interpolated';
    else % cdatashape.isConstantColor - must be 1x3 
        hgfilter('RGBAColorToGeometryPrimitive',hPrim,cdata);
    end
else
    hgfilter('RGBAColorToGeometryPrimitive',hPrim,color);
end

if size(hPrim.ColorData_I,1)==4 && ~strcmp(color,'none')
    hPrim.ColorData_I(4,:) = 255*alpha*ones(1,size(hPrim.ColorData_I,2),'uint8');
    if(alpha ~= 1)
        hPrim.ColorType_I = 'truecoloralpha';
    end
end

% LocalWords:  cdatashape
