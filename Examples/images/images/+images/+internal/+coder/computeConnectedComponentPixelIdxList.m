function pixelIdxList = computeConnectedComponentPixelIdxList(L,ccAreas) %#codegen
%computeConnectedComponentPixelIdxList For internal use only

% Compute the list of pixels belonging to each connected component labeled
% in input image L.
%
% Inputs:
%     L: label image of class double containing nonnegative, integer values
%     ccAreas: vector containing the areas of each connected component so
%              that ccAreas(i) is the number of pixels in CC i.
%
% Output:
%     pixelIdxList: vector containing the linear indices of the pixels
%                   belonging to each connected component in L,
%                   contiguously.
%
% Example workflow:
%     % Call bwlabel to create a label image and count the number of CC
%     [L,numComponents] = bwlabel(BW);
%
%     % Call computeConnectedComponentAreas to find the size of each CC
%     ccAreas = computeConnectedComponentAreas(L,numComponents);
%
%     % Call computeConnectedComponentPixelIdxList to get the locations of
%     % the pixels belonging to each CC
%     pixelIdxList = computeConnectedComponentPixelIdxList(L,ccAreas);
%
%     % Do some processing on the pixels of the connected components
%     ...

% Copyright 2015 The MathWorks, Inc.

coder.inline('always');
coder.internal.prefer_const(L,ccAreas);

% Image size
numPixels = coder.internal.indexInt(numel(L));

% Number of regions
numComponents = numel(ccAreas);

% Total number of foreground pixels
numForegroundPixels = coder.internal.indexInt(0);

% Beginning index for each region
beginIdx = coder.nullcopy(coder.internal.indexInt(zeros(numComponents,1)));

for i = 1:numComponents
    beginIdx(i) = numForegroundPixels;
    numForegroundPixels = coder.internal.indexPlus(numForegroundPixels,ccAreas(i));
end

% Declare pixelIdxList without initializing
pixelIdxList = coder.nullcopy(coder.internal.indexInt(zeros(numForegroundPixels,1)));

% Go through the image and add the location of each foreground pixel to the
% sub-list corresponding to its region
for pixelIdx = 1:numPixels
    pixelVal = coder.internal.indexInt(L(pixelIdx)); % negative = background
    % If foreground pixel
    if (pixelVal > coder.internal.indexInt(0))
        % Increment for each pixel in the region
        beginIdx(pixelVal) = coder.internal.indexPlus(beginIdx(pixelVal),1);
        % Set pixel location in output vector
        pixelIdxList(beginIdx(pixelVal)) = pixelIdx;
    end
end