function B = localcontrast(varargin)
%LOCALCONTRAST Edge-aware local contrast manipulation of images
%
%   B = localcontrast(A) enhances the local contrast of image A using
%   edgeThreshold=0.3 and amount=0.25. A must be M-by-N grayscale or
%   M-by-N-by-3 RGB.
%
%   B = localcontrast(A, edgeThreshold, amount) enhances or flattens the
%   local contrast of A by increasing or smoothing details while leaving
%   strong edges unchanged. edgeThreshold defines the minimum intensity
%   amplitude of strong edges to leave intact. edgeThreshold must be in
%   [0,1]. amount is the amount of enhancement or smoothing desired. amount
%   must be in [-1,1]. Negative values of amount correspond to edge-aware
%   smoothing while positive values correspond to edge-aware enhancement.
%   amount=0 leaves A unchanged, amount=1 strongly enhances the local
%   contrast of A, and amount=-1 strongly smooths its details.
%
%   Class Support
%   -------------
%   A must be a real, non-sparse M-by-N or M-by-N-by-3 matrix of one of the
%   following classes: uint8, uint16, int8, int16 or single. edgeThreshold
%   and amount must be numeric scalars.
%
%   Example
%   -------
%   Increase or reduce the local contrast of an image.
%
%   % Import an RGB image
%   A = imread('peppers.png');
%
%   % First, moderatly increase its local contrast
%   edgeThreshold = 0.4;
%   amount = 0.5;
%   B = localcontrast(A, edgeThreshold, amount);
%
%   % Display the results against the original image
%   imshowpair(A, B, 'montage')
%
%   % Second, reduce its local contrast
%   amount = -0.5;
%   B = localcontrast(A, edgeThreshold, amount);
%
%   Display the new results
%   imshowpair(A, B, 'montage')
%
%   See also IMADJUST, IMCONTRAST, IMSHARPEN, LOCALLAPFILT.

%   Copyright 2016 The MathWorks, Inc.

inputs = parseInputs(varargin{:});

if (inputs.edgeThreshold == 0) || (inputs.amount == 0)
    % Nothing to do
    B = inputs.A;
else
    if (inputs.amount > 0)
        % local contrast increase
        % amount \in [0,+1] <=> alpha \in [0.01,1]
        alpha = 1 - 0.99 * inputs.amount;
        colorMode = 'luminance';
    else
        % local contrast flattening
        % amount \in [-1,0] <=> alpha \in [1,100]
        alpha = 1 - 99 * inputs.amount;
        % avoid color artifacts by filtering
        % each channel independently
        colorMode = 'separate';
    end
    
    B = locallapfilt( ...
        inputs.A, ...
        inputs.edgeThreshold, ...
        alpha, ...
        1, ...
        'NumIntensityLevels', 'auto', ...
        'ColorMode', colorMode);
end

%--------------------------------------------------------------------------
function inputs = parseInputs(varargin)

narginchk(1,3);

parser = inputParser();
parser.FunctionName = mfilename;

% input image
validateImage = @(x) validateattributes(x, ...
    {'single','uint8','uint16','int8','int16'}, ...
    {'real','nonsparse','nonempty'}, ...
    mfilename,'A',1);
parser.addRequired('A', validateImage);

% edgeThreshold must be in [0,1]
defaultEdgeThreshold = 0.3;
validateEdgeThreshold = @(x) validateattributes(x, ...
    {'numeric'}, ...
    {'scalar','real','nonnegative','<=',1,'finite','nonsparse','nonempty'}, ...
    mfilename, 'edgeThreshold', 2);
parser.addOptional( ...
    'edgeThreshold', ...
    defaultEdgeThreshold, ...
    validateEdgeThreshold);

% amount must be in [-1,1]
defaultAmount = 0.25;
validateAmount = @(x) validateattributes(x, ...
    {'numeric'}, ...
    {'scalar','real','>=',-1,'<=',1,'finite','nonsparse','nonempty'}, ...
    mfilename,'alpha',3);
parser.addOptional( ...
    'amount', ...
    defaultAmount, ...
    validateAmount);

parser.parse(varargin{:});
inputs = parser.Results;

% Additional input validation

% A must be MxN grayscale or MxNx3 RGB
validColorImage = (ndims(inputs.A) == 3) && (size(inputs.A,3) == 3);
if ~(ismatrix(inputs.A) || validColorImage)
    error(message('images:validate:invalidImageFormat','A'));
end

inputs.edgeThreshold = double(inputs.edgeThreshold);
inputs.amount = double(inputs.amount);
