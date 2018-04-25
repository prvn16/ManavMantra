function [out,padvec] = padForPyramiding(in,pyramidLevels)
%padForPyramiding Pad input image to be cleanly divisible for pyramiding.

%   Copyright 2014 The MathWorks, Inc.

largestRequiredMultipleOfTwoDivisor = 2.^(pyramidLevels-1);
out = in;

nDims = ndims(in);
padvec = zeros(1,nDims);
for i = 1:nDims
    remainderPixels = mod(size(in,i),largestRequiredMultipleOfTwoDivisor);
    if (remainderPixels)
        padvec(i) = largestRequiredMultipleOfTwoDivisor-remainderPixels;
    else
        padvec(i) = 0;
    end
end
% Arbitrarily choose post style padding.
out = padarray(out,padvec,'replicate','post');
