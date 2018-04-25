function xyz = srgb2xyz(srgb)
%srgb2xyz Convert sRGB colors to XYZ colors
%
%   xyz = srgb2xyz(srgb) converts a P-by-3 matrix of sRGB values to a
%   P-by-3 matrix of XYZ colors assuming an adapted white point of D65.

%   Copyright 2013 The MathWorks, Inc.

srgb_p = srgb;
small = srgb_p <= 0.03928;
srgb_p(small) = srgb_p(small) / 12.92;

not_small = ~small;
srgb_p(not_small) = ((srgb_p(not_small) + 0.055) / 1.055).^2.4;

T = [0.4124 0.3576 0.1805
     0.2126 0.7152 0.0722
     0.0193 0.1192 0.9505];
T = T';

xyz = srgb_p * T;