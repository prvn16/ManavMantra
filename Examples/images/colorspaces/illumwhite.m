function illuminant = illumwhite(varargin)
%ILLUMWHITE Illuminant estimation using the White Patch Retinex method
%
%   illuminant = ILLUMWHITE(A) estimates the illumination of the scene in
%   the input RGB image A under the assumption that the top 1% brightest
%   red, green and blue values represent the color white. The illuminant
%   is returned as a 1-by-3 vector of doubles.
%
%   illuminant = ILLUMWHITE(A,topPercentile) estimates the illumination of
%   the scene in the input RGB image A using the topPercentile% brightest
%   red, green and blue values. topPercentile must be in [0,100). If it is
%   omitted, its value is assumed to be 1.
%
%   illuminant = ILLUMWHITE(___,Name,Value,...) specifies additional
%   options as name-value pairs:
%
%     'Mask'  -  M-by-N logical or numeric array specifying the pixels of
%                the input image A to take into consideration for the
%                estimation of the illuminant. Pixels of A corresponding to
%                zero values in the mask are excluded from the computation.
%
%                Default: true(size(A,1), size(A,2))
%
%   Class Support
%   -------------
%   A must be a real, non-sparse, M-by-N-by-3 RGB image of one
%   of the following classes: uint8, uint16, single or double.
%
%   Notes
%   -----
%   [1] The White Patch Retinex algorithm assumes uniform illumination and
%   linear RGB values, although the algorithm also works in practice for
%   non-linear RGB values such as sRGB.
%
%   [2] Set topPercentile to 0 to return the maximum red, green and blue
%   values.
%
%   Example 1
%   ---------
%   Correct the white balance of an image using the White Patch algorithm
%
%     % Open an image
%     A = imread('hallway.jpg');
%
%     % Estimate the scene illumination from the top 5% brightest pixels
%     topPercentile = 5;
%     illuminant = illumwhite(A, topPercentile);
%
%     % Correct colors using the estimated illuminant
%     B = chromadapt(A, illuminant);
%
%     % Display the original and corrected images
%     figure
%     imshowpair(A,B,'montage')
%     title(['White balancing with White Patch and topPercentile=' ...
%         num2str(topPercentile)])
%
%   Example 2
%   ---------
%   Estimate the scene illumination excluding over-exposed pixels
%
%     % Open an image
%     A = imread('micromarket.jpg');
%
%     % Find over-exposed pixels in the red, green and blue channels
%     overexposed = A == uint8(255);
%
%     % Combine the three channels
%     overexposed = overexposed(:,:,1) | overexposed(:,:,2) | overexposed(:,:,3);
%
%     % Dilate the mask covering over-exposed pixels to exclude nearby pixels
%     overexposed = imdilate(overexposed, ones(21));
%
%     % Estimate the scene illumination excluding the over-exposed pixels
%     illuminant = illumwhite(A, 'Mask', ~overexposed)
%
%     % Correct colors using the estimated illuminant
%     B = chromadapt(A, illuminant);
%
%     % Display the original and corrected images
%     figure
%     imshowpair(A,B,'montage')
%     title('White balancing with White Patch excluding over-exposed pixels')
%
%   See also CHROMADAPT, ILLUMGRAY, ILLUMPCA, LIN2RGB, RGB2LIN.

%   Copyright 2016 The MathWorks, Inc.

%   Reference
%   ---------
%   Ebner, Marc. White Patch Retinex, Color Constancy.
%   John Wiley & Sons, 2007. ISBN 978-0-470-05829-9.

[A,p,mask] = parseInputs(varargin{:});

numBins = 2^8;
if ~isa(A,'uint8')
    numBins = 2^16;
end

illuminant = zeros(1,3,'like',A);
for k = 1:3
    plane = A(:,:,k);
    plane = plane(mask);
    if isempty(plane)
        error(message('images:awb:maskExpectedNonZero','Mask'))
    end
    [counts, binLocations] = imhist(plane, numBins);
    cumhist = cumsum(counts,'reverse');
    idx = find(cumhist > numel(plane) * p/100);
    if ~isempty(idx)
        illuminant(k) = binLocations(idx(end));
    end
end
illuminant = im2double(illuminant);

%--------------------------------------------------------------------------
function [A,p,mask] = parseInputs(varargin)

narginchk(1,4);

parser = inputParser();
parser.FunctionName = mfilename;

% A
validateImage = @(x) validateattributes(x, ...
    {'single','double','uint8','uint16'}, ...
    {'real','nonsparse','nonempty'}, ...
    mfilename,'A',1);
parser.addRequired('A', validateImage);

% percentile
defaultPercentile = 1;
validatePercentile = @(x) validateattributes(x, ...
    {'numeric'}, ...
    {'real','nonsparse','nonempty','nonnan','scalar','nonnegative','<',100}, ...
    mfilename,'percentile',2);
parser.addOptional('percentile', ...
    defaultPercentile, ...
    validatePercentile);

% NameValue 'Mask'
defaultMask = true;
validateMask = @(x) validateattributes(x, ...
    {'logical','numeric'}, ...
    {'real','nonsparse','nonempty','2d','nonnan'}, ...
    mfilename,'Mask');
parser.addParameter('Mask', ...
    defaultMask, ...
    validateMask);

parser.parse(varargin{:});
inputs = parser.Results;
A    = inputs.A;
p    = double(inputs.percentile);
mask = inputs.Mask;

% Additional validation

% A must be MxNx3 RGB
validColorImage = (ndims(A) == 3) && (size(A,3) == 3);
if ~validColorImage
    error(message('images:validate:invalidRGBImage','A'));
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
