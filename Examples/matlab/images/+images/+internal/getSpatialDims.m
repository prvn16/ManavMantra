function [imageWidth,imageHeight] = getSpatialDims(hIm)
%getSpatialDims returns the overall spatial dimensions of an R-Set or
%non-R-Set image.
%
% [imageWidth,imageHeight] = getSpatialDims(hIm) returns the spatial dimensions of the image
% hIm.

%   Copyright 2008-2014 The MathWorks, Inc.

cdata = get(hIm,'CData');
xdata = get(hIm,'XData');
imageWidth  = size(cdata,2);
imageHeight = size(cdata,1);

% pixels must be square so we can use dx for both dims
dxOnePixel = images.internal.getDeltaOnePixel(xdata,imageWidth);
imageWidth  = imageWidth  * dxOnePixel;
imageHeight = imageHeight * dxOnePixel;