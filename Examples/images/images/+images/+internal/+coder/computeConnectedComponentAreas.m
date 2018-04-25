function ccAreas = computeConnectedComponentAreas(L,numComponents) %#codegen
%computeConnectedComponentAreas For internal use only

% Compute the number of pixels belonging to each connected component
% labeled in input image L
%
% Inputs:
%     L: label image of class double containing nonnegative, integer values
%     numComponents: number of connected components in L
%
% Output:
%     ccAreas: vector containing the areas of each connected component so
%              that ccAreas(i) is the number of pixels in CC i. 
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
coder.internal.prefer_const(L,numComponents);

% Image size
numPixels = coder.internal.indexInt(numel(L));

% Initialize regionLengths output array to 0
ccAreas = coder.internal.indexInt(zeros(numComponents,1));

for pixelIdx = 1:numPixels
    pixelVal = coder.internal.indexInt(L(pixelIdx)); % negative = background
    % If foreground pixel
    if (pixelVal > coder.internal.indexInt(0))
        % Increment pixel count for that region
        ccAreas(pixelVal) = coder.internal.indexPlus(ccAreas(pixelVal),1);
    end
end