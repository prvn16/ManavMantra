function RGB = demosaic(I, sensorAlignment)
%DEMOSAIC Convert Bayer pattern encoded image to a truecolor image.
%   RGB = DEMOSAIC(I, sensorAlignment) converts a Bayer pattern encoded
%   image to a truecolor image using gradient-corrected linear
%   interpolation. I is an M-by-N array of intensity values that are Bayer
%   pattern encoded. I must have at least 5 rows and 5 columns.
%
%   Bayer pattern encoding refers to various arrangements of color filters
%   that let each sensor in a single-sensor digital camera record only red,
%   green, or blue data. The patterns emphasize the number of green sensors
%   to mimic the human eye's greater sensitivity to green light. The
%   DEMOSAIC function uses interpolation to convert the two-dimensional
%   Bayer-encoded image into the truecolor image, RGB, which is an
%   M-by-N-by-3 array.
%
%   sensorAlignment is one of the following strings or char vectors that
%   specifies the Bayer pattern. Each string or char vector represents the
%   order of the red, green, and blue sensors by describing the four pixels
%   in the upper-left corner of the image (left-to-right, top-to-bottom).
%
%   Value     2-by-2 Sensor Alignment
%   ------    -----------------------
%   'gbrg'     green  blue
%              red    green
%
%   'grbg'     green  red
%              blue   green
%
%   'bggr'     blue   green
%              green  red
%
%   'rggb'     red    green
%              green  blue
%
%   Class Support
%   -------------
%   I can be uint8, uint16 or uint32, and it must be real. RGB has the same
%   class as I.
%
%   Example
%   -------
%   Demosaic a Bayer pattern encoded-image that was photographed by a
%   camera with a sensor alignment of 'bggr'.
%
%       I = imread('mandi.tif');
%       J = demosaic(I,'bggr');
%       imshow(I);
%       figure, imshow(J);

%   Copyright 2007-2015 The MathWorks, Inc.

%   Reference
%   ---------
%   Malvar, H.S., L. He, and R. Cutler, "High quality linear
%   interpolation for demosaicing of Bayer-patterned color images", ICASPP,
%   2004.

validateattributes(I,{'uint8','uint16','uint32'},{'real','2d'}, ...
    mfilename, 'I',1);

sensorAlignment = validatestring(sensorAlignment, ...
    {'gbrg', 'grbg', 'bggr', 'rggb'}, mfilename, ...
    'sensorAlignment',2);

sizeI = size(I);
if (sizeI(1) < 5 || sizeI(2) < 5)
    error(message('images:demosaic:invalidImageSize'));
end

RGB = demosaicmex(I, sensorAlignment);

