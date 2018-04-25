function rgb = rgbe2rgb(rgbe)
%rgbe2rgb    Convert RGBE values to floating-point RGB.
%   RGB = RGBE2RGB(RGBE) converts an arry of (R,G,B,E) encoded values to
%   an array of floating-point (R,G,B) high dynamic range values.
%
%   Reference: Ward, "Real Pixels" (pp. 80-83) in Arvo "Graphics Gems II," 1991.

%   Copyright 2007-2013 The MathWorks, Inc.

dims = size(rgbe);

% Separate the 1-D scanline into separate columns of (R,G,B,E) values.
rgbe = reshape(rgbe, dims(1), 4);

rgb = bsxfun(@times, single(rgbe(:, 1:3)) ./ 256, ...
                     2.^(single(rgbe(:,4)) - 128));

% Esnure that (0,0,0,0) maps to (0,0,0).
mask = max(rgbe, [], 2) == 0;
rgb(mask,:) = 0;

% Separate into color planes suitable for storage.
rgb = reshape(rgb, [dims(1), 1, 3]);
