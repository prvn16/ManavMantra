function sRGB = Lab2sRGB(Lab)
%Lab2sRGB   Convert L*a*b* images to sRGB.

%   Copyright 2013 The MathWorks, Inc.

import images.internal.lab2xyz;
import images.internal.xyz2srgb;

% Convert to canonical form (m*n-by-3 floating point).
origShape = size(Lab);
%Lab_f = reshape(im2single(Lab), [], 3);
Lab = reshape(Lab, [], 3);

% Convert Lab to sRGB via XYZ.
sRGB = xyz2srgb(lab2xyz(Lab));

% Convert back to original shape and datatype.
sRGB = reshape(sRGB, origShape);
