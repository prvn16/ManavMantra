function I = resizeImageToFitWithinAxes(hAx,I)

%   Copyright 2013 The MathWorks, Inc.

axesPixelPosition = getpixelposition(hAx);
axesSizeInPixels = axesPixelPosition(3:4);
imSize = size(I);

sizeRatio = axesSizeInPixels ./ imSize(1:2);
[minRatio,dim] = min(sizeRatio);
needToDownsample = minRatio < 1;
% If the image grid in pixels is larger than the axes in pixels
% along the limiting dimension, resize the input image with
% anti-aliasing.
if needToDownsample
    % We use the feature of imresize in which [NaN numCols] or [numRows Nan] is
    % interpreted as resize to this number of rows,cols and preserve aspect
    % ratio.
    imresizeOutputSize = nan(1,2);
    imresizeOutputSize(dim) = axesSizeInPixels(dim);
    
    I = imresize(I,imresizeOutputSize);
end