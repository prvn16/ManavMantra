function RGBldr = tonemap(HDR, varargin)
%TONEMAP   Render high dynamic range image for viewing.
%   RGB = TONEMAP(HDR) performs tone mapping on the high dynamic range
%   image HDR to a lower dynamic range image RGB suitable for display.
%
%   RGB = TONEMAP(HDR, 'AdjustLightness', [LOW HIGH], ...) adjusts the
%   overall lightness of the rendered image by passing the luminance
%   values of the low dynamic range image to IMADJUST with the values LOW
%   and HIGH, which are in the range [0, 1].
%
%   RGB = TONEMAP(HDR, 'AdjustSaturation', SCALE, ...) adjusts the
%   saturation of colors in the rendered image.  When SCALE is greater
%   than 1, the colors are more saturated.  A SCALE value in the range
%   [0, 1) results in less saturated colors. This parameter has no effect
%   on grayscale images.
%
%   RGB = TONEMAP(HDR, 'NumberOfTiles', [ROWS COLS], ...) sets the number
%   of tiles used during the adaptive histogram equalization part of the
%   tone mapping operation.  ROWS and COLS specify the number of tile rows
%   and columns.  Both ROWS and COLS must be at least 2.  The total number
%   of image tiles is equal to ROWS * COLS.  A larger number of tiles
%   results in an image with greater local contrast.  The default for ROWS
%   and COLS is 4.
%
%   Class Support
%   -------------
%   The high dynamic range image HDR must be a M-by-N or M-by-N-by-3 array
%   of class single or double. The output image RGB is a uint8 array of the
%   same size as HDR.
%
%   Example
%   -------
%   Load a high dynamic range image, convert it to a low dynamic range
%   image while deepening shadows and increasing saturation, and display
%   the results.
%
%       hdr = hdrread("office.hdr");
%       imshow(hdr)
%       rgb = tonemap(hdr, "AdjustLightness", [0.1 1], ...
%                     "AdjustSaturation", 1.5);
%       figure;
%       imshow(rgb);
%
%   See also ADAPTHISTEQ, HDRREAD, LOCALTONEMAP, MAKEHDR, STRETCHLIM.

%   Copyright 2007-2017 The MathWorks, Inc.

% Parse and validate input arguments.
validateattributes(HDR, {'single', 'double'}, {'real'}, mfilename, 'RGBhdr', 1);
% HDR must be MxN or MxNx3
validColorImage = (ndims(HDR) == 3) && (size(HDR,3) == 3);
if ~(ismatrix(HDR) || validColorImage)
    error(message('images:validate:invalidImageFormat','HDR'));
end

varargin = matlab.images.internal.stringToChar(varargin);
options = parseArgs(varargin{:});

% Transform the HDR image to a new HDR image in the range [0,1] by taking
% the base-2 logarithm and linearly scaling it.
[RGBlog2Scaled, hasNonzero] = lognormal(HDR);

% Convert the image to a low dynamic range image by adaptive histogram
% equalization.
if (hasNonzero)
    RGBldr = toneOperator(RGBlog2Scaled, ...
                          options.AdjustLightness, ...
                          options.AdjustSaturation, ...
                          options.NumberOfTiles);
else
    % "HDR" image only has zeros.  Return another image of zeros.
    RGBldr = RGBlog2Scaled;
end

RGBldr = im2uint8(RGBldr);

function options = parseArgs(varargin)
% Get user-provided and default options.

parser = inputParser();
parser.FunctionName = mfilename;

% NameValue 'AdjustLightness'
defaultAdjustLightness = [0 1];
validateAdjustLightness = @(x) validateattributes(x, ...
    {'double'}, ...
    {'nonempty','vector','real','nonnan','nonnegative','<=',1}, ...
    mfilename,'AdjustLightness');
parser.addParameter('AdjustLightness', ...
    defaultAdjustLightness, ...
    validateAdjustLightness);

% NameValue 'AdjustSaturation'
defaultAdjustSaturation = 1;
validateAdjustSaturation = @(x) validateattributes(x, ...
    {'double'}, ...
    {'scalar','real','nonnan','nonnegative'}, ...
    mfilename,'AdjustSaturation');
parser.addParameter('AdjustSaturation', ...
    defaultAdjustSaturation, ...
    validateAdjustSaturation);

% NameValue 'NumberOfTiles'
defaultNumberOfTiles = [4 4];
validateNumberOfTiles = @(x) validateattributes(x, ...
    {'double'}, ...
    {'nonempty','vector','integer','real','finite','positive','nonzero'}, ...
    mfilename,'NumberOfTiles');
parser.addParameter('NumberOfTiles', ...
    defaultNumberOfTiles, ...
    validateNumberOfTiles);

parser.parse(varargin{:});
options = parser.Results;

function [RGBlog2Scaled, hasNonzero] = lognormal(RGBhdr)
% Take the base-2 logarithm of an HDR image and return another HDR in [0,1].

% Remove 0's from each channel.  This can change color quality, but it's
% unlikely to have a big impact and prevents log(0) --> -inf.  That's worse.
minNonzero = min(RGBhdr(RGBhdr ~= 0));

if (isempty(minNonzero))
    RGBlog2Scaled = zeros(size(RGBhdr), class(RGBhdr));
    hasNonzero = false;

else
    RGBhdr(RGBhdr == 0) = minNonzero;

    % Ward's method equalizes the log-luminance histogram.
    RGBlog2 = log2(RGBhdr);
    RGBlog2Scaled = mat2gray(RGBlog2); % Normalize to [0,1]
    hasNonzero = true;
end

function RGBldr = toneOperator(RGBlog2Scaled, LRemap, saturation, numtiles)
% Convert the image from HDR to LDR.

if ismatrix(RGBlog2Scaled)
    % If the image is grayscale, simply adjust the log-intensity
    RGBldr = adapthisteq(RGBlog2Scaled, 'NumTiles', numtiles);
    RGBldr = imadjust(RGBldr, LRemap, [0 1]);
else
    % Colorspaces for HDR imagery is tricky.  For simplicity, assign the
    % log-luminance image to be in sRGB.
    Lab = rgb2lab(RGBlog2Scaled);
    
    % Tone map the L* values from the RGB HDR to preserve overall color as much
    % as possible.  This decreases global saturation, which can be reintroduced
    % by scaling the a* and b* channels.
    Lab(:,:,1) = Lab(:,:,1) ./ 100;
    Lab(:,:,1) = adapthisteq(Lab(:,:,1), 'NumTiles', numtiles);
    Lab(:,:,1) = imadjust(Lab(:,:,1), LRemap, [0 1]) * 100;
    Lab(:,:,2) = Lab(:,:,2) * saturation;
    Lab(:,:,3) = Lab(:,:,3) * saturation;
    
    % Convert the image back to sRGB.
    RGBldr = lab2rgb(Lab);
end
