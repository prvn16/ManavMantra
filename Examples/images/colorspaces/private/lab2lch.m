function lch = lab2lch(lab)
%LAB2LCH Converts CIELAB to Lightness, Chroma, Hue
%   lch = LAB2XYZ(lab) converts 1976 CIELAB to
%   Lightness, Chroma, Hue (in degrees 0 to 360).
%   Both lch and lab are n x 3 vectors
%
%   Example: 
%       lch = lab2lch([90 10 10])
%           90.0000   14.1421   45.0000

%   Copyright 1993-2015 The MathWorks, Inc.
%
%   Author:  Scott Gregory, 10/18/02
%   Revised: Toshia McCabe, 11/17/02

validateattributes(lab,{'double'},{'real','2d','nonsparse','finite'},...
'lab2lch','LAB',1);
if size(lab,2) ~= 3
    error(message('images:lab2lch:invalidLabData'))
end

lch = zeros(size(lab));
lch(:,1) = lab(:,1);
lch(:,2) = sqrt(lab(:,2).^2 + lab(:,3).^2);
lch(:,3) = mod(atan2(lab(:,3), lab(:,2)) * 180/pi, 360);
