function Lab = sRGB2Lab(sRGB)
%sRGB2Lab   Convert sRGB images to L*a*b*.

%   Copyright 2013 The MathWorks, Inc.

import images.internal.srgb2xyz;
import images.internal.xyz2lab;

% Convert to canonical form (m*n-by-3 floating point).
origShape = size(sRGB);
sRGB_f = reshape(im2single(sRGB), [], 3);

% Convert sRGB to Lab via XYZ.
Lab = xyz2lab(srgb2xyz(sRGB_f));

% Convert back to original shape and datatype.
Lab = reshape(Lab, origShape);
