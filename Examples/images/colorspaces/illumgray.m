function illuminant = illumgray(varargin)
%ILLUMGRAY Illuminant estimation using the Gray World method
%
%   illuminant = ILLUMGRAY(A) estimates the illumination of the scene in
%   the input RGB image A under the assumption that the average color of
%   the scene is gray. To prevent over-exposed and under-exposed pixels
%   from skewing the estimation, the top and bottom 1% of pixels ordered by
%   brightness are excluded from the computation. The illuminant is
%   returned as a 1-by-3 vector of doubles.
%
%   illuminant = ILLUMGRAY(A,[bottomPercentile topPercentile]) specifies
%   the bottom and top percentiles to exclude from the estimation of the
%   illuminant. If a scalar value is specified, it is used for both
%   bottomPercentile and topPercentile. bottomPercentile and topPercentile
%   must both be in [0,100) and their sum cannot exceed 100. If the
%   percentiles are omitted, their values are assumed to be 1.
%
%   illuminant = ILLUMGRAY(___,Name,Value,...) specifies additional options
%   as name-value pairs:
%
%     'Mask'  -  M-by-N logical or numeric array specifying the pixels of
%                the input image A to take into consideration for the
%                estimation of the illuminant. Pixels of A corresponding to
%                zero values in the mask are excluded from the computation.
%
%                Default: true(size(A,1), size(A,2))
%
%     'Norm'  -  Scalar specifying the type of p-norm used in the
%                calculation of the average RGB value in the input image.
%                The p-norm is defined as sum(abs(x)^p)^(1/p).
%
%                Default: 1
%
%   Class Support
%   -------------
%   A must be a real, non-sparse, M-by-N-by-3 RGB image of one
%   of the following classes: uint8, uint16, single or double.
%
%   Notes
%   -----
%   [1] The Gray World algorithm assumes uniform illumination and linear
%   RGB values. If you are working with (non-linear) sRGB images, use the
%   rgb2lin function to undo the gamma correction before using ILLUMGRAY.
%   Additionally, make sure to convert the chromatically adapted image back
%   to sRGB by gamma correcting it for display with the lin2rgb function.
%
%   [2] The 'Mask' parameter is used in addition to the bottomPercentile
%   and topPercentile parameters. When it is used, the bottomPercentile and
%   topPercentile apply to the masked image.
%
%   [3] bottomPercentile specifies the share of dark pixels to exclude from
%   the computation when they are ordered from darkest to brightest.
%   topPercentile specifies the share of bright pixels to exclude when they
%   are ordered from brightest to darkest. For example, in the illustration
%   below, pixels are ordered from darkest to brightest from left to right.
%   The dark pixels to exclude are the 42% darkest. The bright pixels to
%   exclude are the 18% brightest.
%
%            bottomPercentile = 42                topPercentile = 18
%           |-------------------->                    <--------|
%           |                    |                    |        |
%   darkest [--------------------------------------------------] brightest
%           |                    |                    |        |
%           |                pixels taken into consideration   |
%           |                    [--------------------]        |
%
%   Reference
%   ---------
%   Ebner, Marc. The Gray World Assumption, Color Constancy.
%   John Wiley & Sons, 2007. ISBN 978-0-470-05829-9.
%
%   Example 1
%   ---------
%   Correct the white balance of an image using the Gray World algorithm
%
%     % Open an image
%     A = imread('foosball.jpg');
%
%     % Gray World assumes linear RGB values. Therefore,
%     % before applying the algorithm, first linearize
%     % the input image by undoing its gamma correction.
%     A_lin = rgb2lin(A);
%
%     % Estimate the scene illumination excluding the top
%     % and bottom 10% of pixels. Note that, since the
%     % input image has been linearized, the illuminant
%     % is returned in linear RGB space.
%     percentiles = 10;
%     illuminant = illumgray(A_lin, percentiles);
%
%     % Correct colors using the estimated illuminant
%     B_lin = chromadapt(A_lin, illuminant, 'ColorSpace', 'linear-rgb');
%
%     % Apply a gamma correction to the corrected image
%     % in order to display it correctly on the screen.
%     B = lin2rgb(B_lin);
%
%     % Display the original and corrected images
%     figure
%     imshowpair(A,B,'montage')
%     title(['White balancing with Gray World and percentiles=[' ...
%         num2str(percentiles) ' ' num2str(percentiles) ']'])
%
%   See also CHROMADAPT, ILLUMPCA, ILLUMWHITE, LIN2RGB, RGB2LIN.

%   Copyright 2016 The MathWorks, Inc.

[A,percentiles,mask,exponent] = parseInputs(varargin{:});

lowPercentile = percentiles(1);
highPercentile = percentiles(2);

numBins = 2^8;
if ~isa(A,'uint8')
    numBins = 2^16;
end

illuminant = zeros(1,3);
for k = 1:size(A,3)
    plane = A(:,:,k);
    plane = plane(mask);
    if isempty(plane)
        error(message('images:awb:maskExpectedNonZero','Mask'))
    end
    [counts, binLocations] = imhist(plane, numBins);
    
    cumhistLow = cumsum(counts);
    idxLow = find(cumhistLow > numel(plane) * lowPercentile/100,1,'first');
    minVal = binLocations(idxLow);
    
    cumhistHigh = cumsum(counts,'reverse');
    idxHigh = find(cumhistHigh > numel(plane) * highPercentile/100,1,'last');
    maxVal = binLocations(idxHigh);
    
    if isfloat(A)
        % Since the histogram has only 16 bits of precision,
        % loosen the condition to avoid excluding values that
        % would have otherwise been taken into consideration.
        epsilon = 1e-5;
        mask2 = plane <= maxVal+epsilon & plane >= minVal-epsilon;
    else
        mask2 = plane <= maxVal & plane >= minVal;
    end
    pixelValues = im2double(plane(mask2));
    illuminant(k) = norm(pixelValues, exponent) / numel(pixelValues);
end

%--------------------------------------------------------------------------
function [A,percentiles,mask,exponent] = parseInputs(varargin)

narginchk(1,6);

parser = inputParser();
parser.FunctionName = mfilename;

% A
validateImage = @(x) validateattributes(x, ...
    {'single','double','uint8','uint16'}, ...
    {'real','nonsparse','nonempty'}, ...
    mfilename,'A',1);
parser.addRequired('A', validateImage);

% Bottom and top percentiles to ignore
defaultPercentiles = 1;
validatePercentiles = @(x) validateattributes(x, ...
    {'numeric'}, ...
    {'real','nonsparse','nonempty','nonnan','vector','nonnegative','<',100}, ...
    mfilename,'[bottomPercentile topPercentile]',2);
parser.addOptional('percentiles', ...
    defaultPercentiles, ...
    validatePercentiles);

% NameValue 'Mask'
defaultMask = true;
validateMask = @(x) validateattributes(x, ...
    {'logical','numeric'}, ...
    {'real','nonsparse','nonempty','2d','nonnan'}, ...
    mfilename,'Mask');
parser.addParameter('Mask', ...
    defaultMask, ...
    validateMask);

% NameValue 'Norm'
defaultNorm = 1;
validateNorm = @(x) validateattributes(x, ...
    {'numeric'}, ...
    {'real','nonsparse','nonempty','nonnan','scalar','positive'}, ...
    mfilename,'Norm');
parser.addParameter('Norm', ...
    defaultNorm, ...
    validateNorm);

parser.parse(varargin{:});
inputs = parser.Results;
A           = inputs.A;
percentiles = double(inputs.percentiles);
mask        = inputs.Mask;
exponent    = double(inputs.Norm);

% Additional validation

% A must be MxNx3 RGB
validColorImage = (ndims(A) == 3) && (size(A,3) == 3);
if ~validColorImage
    error(message('images:validate:invalidRGBImage','A'));
end

if isscalar(percentiles)
    percentiles = [percentiles percentiles];
else
    validateattributes(percentiles, ...
        {'numeric'},{'vector','numel',2}, ...
        mfilename,'percentiles',2);
end

if (sum(percentiles) > 100)
    error(message('images:awb:percentilesMustNotOverlap', ...
        '[bottomPercentile topPercentile]',2, ...
        num2str(percentiles(1)), num2str(percentiles(2)), ...
        num2str(sum(percentiles))))
end

if isequal(mask, defaultMask)
    mask = true(size(A,1),size(A,2));
end

% The sizes of A and Mask must agree
if (size(A,1) ~= size(mask,1)) || (size(A,2) ~= size(mask,2))
    error(message('images:validate:unequalNumberOfRowsAndCols','A','Mask'));
end

% Convert to logical
mask = logical(mask);
