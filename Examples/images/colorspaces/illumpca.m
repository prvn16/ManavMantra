function illuminant = illumpca(varargin)
%ILLUMPCA Illuminant estimation using PCA on bright and dark pixels
%
%   illuminant = ILLUMPCA(A) estimates the illuminant of the scene in the
%   input RGB image A from large color differences. The function chooses
%   bright and dark pixels in the image in order to retain only large color
%   differences. The illuminant is then computed as the dominant direction
%   in the distribution of the selected colors using principal component
%   analysis (PCA). The illuminant is returned as a 1-by-3 vector of
%   doubles.
%
%   illuminant = ILLUMPCA(A,percentage) estimates the illuminant of the
%   scene in the input RGB image A using a specified percentage of darkest
%   and brightest pixels. If percentage is omitted, its value is assumed to
%   be 3.5.
%
%   illuminant = ILLUMPCA(___,Name,Value,...) specifies additional options
%   as name-value pairs:
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
%   A must be a real, non-sparse, M-by-N-by-3 RGB image of one of the
%   following classes: uint8, uint16, single or double.
%
%   Notes
%   -----
%   [1] The algorithm treats pixel colors as vectors in a 3-dimensional
%   space (RGB). Colors are ordered according to the brightness (or norm)
%   of their projection on the average color in the image. By default, only
%   the 3.5% darkest and brighest colors, according to this ordering, are
%   retained. Principal Component Analysis (PCA) is then performed on the
%   subset of colors. The illuminant is estimated as the first component of
%   the PCA.
%
%   [2] The algorithm assumes uniform illumination and linear RGB values.
%   If you are working with (non-linear) sRGB or Adobe RGB images, use the
%   rgb2lin function to undo the gamma correction before using ILLUMPCA.
%   Additionally, make sure to convert the chromatically adapted image back
%   to sRGB or Adobe RGB by gamma correcting it for display with the
%   lin2rgb function.
%
%   [3] percentage represents the share of the brightest and darkest pixels
%   to consider and must be, thus, in (0,50].
%
%   Reference
%   ---------
%   Cheng, Dongliang, Dilip K. Prasad, and Michael S. Brown. "Illuminant
%   estimation for color constancy: why spatial-domain methods work and
%   the role of the color distribution." JOSA A 31.5 (2014): 1049-1058.
%
%   Example 1
%   ---------
%   Correct the white balance of an image using PCA
%
%     % Open an image
%     A = imread('foosball.jpg');
%
%     % ILLUMPCA assumes linear RGB values. Therefore,
%     % before applying the algorithm, first linearize
%     % the input image by undoing its gamma correction.
%     A_lin = rgb2lin(A);
%
%     % Estimate the scene illumination using the darkest
%     % and brighest 3.5% of pixels. Note that, since the
%     % input image has been linearized, the illuminant is
%     % returned in linear RGB space.
%     illuminant = illumpca(A_lin);
%
%     % Correct the color balance using the estimated illuminant
%     B_lin = chromadapt(A_lin, illuminant, 'ColorSpace', 'linear-rgb');
%
%     % Apply a gamma correction to the corrected image
%     % in order to display it correctly on the screen.
%     B = lin2rgb(B_lin);
%
%     % Display the original and corrected images
%     figure
%     imshowpair(A,B,'montage')
%     title('White balancing using Cheng''s method')
%
%   See also CHROMADAPT, ILLUMGRAY, ILLUMWHITE, LIN2RGB, RGB2LIN.

%   Copyright 2016-2017 The MathWorks, Inc.

[A,p,mask] = parseInputs(varargin{:});

% Apply mask
R = A(:,:,1); R = R(mask);
if isempty(R)
    error(message('images:awb:maskExpectedNonZero','Mask'))
end
G = A(:,:,2); G = G(mask);
B = A(:,:,3); B = B(mask);

% Convert to floating point and arrange colors in a list of shape Mx3
if isa(A,'double')
    convert = @(x) x;
else
    convert = @im2single;
end
A = convert([R(:) G(:) B(:)]);

% Pick the top and bottom p% of the colors ordered according to the
% magnitude of their projections along the mean image color.

% Average color in the image
A0 = mean(A,1);
normA02 = sum(A0.^2,2);

% If there is an Inf or NaN anywhere in A, then normA02 is Inf or NaN.
% Validate that A does not contain any Inf/NaN here because it's cheaper.
validateattributes(normA02,{'numeric'},{'nonnan','finite'},mfilename,'A',1);

% Calculate the norm of the projections of the colors on the average color:
% The projection of a vector u on a vector v is a vector with direction
% v/|v| and norm |u| cos(theta) with cos(theta) = u.v / (|u| |v|).
% Here, u is a row of A and v is A0. We only care about the magnitudes
% of the projections, which are thus:
d = sum(A .* A0, 2) ./ normA02;

% Sort the colors according to the magnitude of their projections
[~,i] = sort(d);
sortedA = A(i,:);

if (p >= 50) || (size(A,1) == 1)
    % Use all the colors
    selected = sortedA;
else
    lowIdx = max(1, floor(p/100 * size(A,1)));
    highIdx = size(A,1) - lowIdx + 1;
    selected = [sortedA(1:lowIdx,:); sortedA(highIdx:end,:)];
end

% Principal Component Analysis to determine the main direction
% Note - NOT mean centered to ensure illuminant goes through the origin.
[~,S,V] = svd(selected,0);

if isDegenerateCase(selected,S,V)
    % Return the average of the selected colors
    illuminant = double(mean(selected,1));
else
    % Principal component
    illuminant = double(V(:,1)');
    % Flip direction to 1st quadrant, if it ends up in the 8th quadrant.
    illuminant = abs(illuminant);
end

%--------------------------------------------------------------------------
function tf = isDegenerateCase(A,S,V)

% Degenerate case if any of the following is true (in that order):
%   * There is only one color in the image
%   * The singular vectors form the standard basis
%   * The singular values are equal up to a few machine epsilon
%
% In this case, PCA is not reliable: we don't know which component to
% choose. Use the average color instead of PCA.

epsilon = 10 * eps(class(A));
tf = (size(A,1) < 2) || isequal(V,eye(3,class(A))) || ...
    (S(1)-S(5)) <= epsilon && (S(1)-S(9)) <= epsilon;

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

% Share of darkest and brighest colors to use
defaultPercentage = 3.5;
validatePercentage = @(x) validateattributes(x, ...
    {'numeric'}, ...
    {'real','nonsparse','nonempty','nonnan','scalar','positive','<=',50}, ...
    mfilename,'percentage',2);
parser.addOptional('percentage', ...
    defaultPercentage, ...
    validatePercentage);

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
p    = double(inputs.percentage);
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
