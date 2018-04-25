function rgbe = rgb2rgbe(rgb)
%rgb2rgbe  Convert RGB HDR pixels to 8-bit RGBE components.
%   RGBE = RGB2RGBE(RGB) converts an arry of floating-point, high dynamic
%   range (R,G,B) values to an encoded UINT8 array of (R,G,B,E) values.
%
%   Reference: Ward, "Real Pixels" (pp. 80-83) in Arvo "Graphics Gems II," 1991.

% Copyright 2007-2013 The MathWorks, Inc.

% Reshape the m-by-n-by-3 RGB array into a m*n-by-3 array and find the
% maximum value of each RGB triple.
rgb = reshape(rgb, numel(rgb)/3, 3);

maxRGB = max(rgb,[],2);
[f,e] = log2(maxRGB);
tmp = f*256./maxRGB;  % Reusing maxRGB causes NaN values.
rgbm = bsxfun(@times,rgb,tmp);
rgbe = uint8([rgbm, e+128]);

% Pixels where max(rgb) < 1e-38 must become (0,0,0,0).
mask = find(maxRGB < 1e-38);
rgbe(mask, :) = repmat([0 0 0 0], [numel(mask), 1]);
