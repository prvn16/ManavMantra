function imageHeight = getImHeight(hIm)
%getImHeight returns the overall spatial height of an R-Set or non-R-Set
%image.
%
% imageWidth = getImWidth(hIm) returns the spatial height of the image
% hIm.

%   Copyright 2008-2014 The MathWorks, Inc.

if images.internal.isRSetImage(hIm)
    [~,imageHeight] = images.internal.getSpatialDims(hIm);
else
    img = get(hIm,'cdata');
    imageHeight = size(img,1);
end
