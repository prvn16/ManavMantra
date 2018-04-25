function validatePyramiding(moving,fixed,pyramidLevels)
%validatePyramiding Validate pyramiding is valid based on image size.
%
% validatePyramiding(moving,fixed,pyramidLevels) enforces that the minimum
% image size that can result from pyramiding with N levels as a 2x2 or
% 2x2x2 image at the lowest resolution level of the pyramid.

%   Copyright 2014 The MathWorks, Inc.

minDimSize = 2^pyramidLevels;
if any(size(moving) < minDimSize) || any(size(fixed) < minDimSize)
    error(message('images:imregdemons:imageDimsToSmallForPyramidLevels',pyramidLevels,'MOVING','FIXED',minDimSize));
end