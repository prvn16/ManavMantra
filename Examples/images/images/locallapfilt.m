function output = locallapfilt(varargin)
%LOCALLAPFILT Fast Local Laplacian Filtering of images
%
%   B = locallapfilt(A, sigma, alpha, beta) filters image A with an
%   edge-aware Fast Local Laplacian Filter parameterized by sigma, alpha
%   and beta. sigma characterizes the amplitude of edges in A. Variations
%   of intensity smaller than sigma are considered details, while
%   variations greater than sigma are considered edges, which are preserved
%   by the filter. If alpha is less than 1, the details of A are increased,
%   effectively enhancing the local contrast of A without affecting edges
%   or introducing halos. If alpha is greater than 1, details are smoothed
%   out while preserving crisp edges. If alpha is equal to 1, the details
%   of A are left unchanged. beta is used to manipulate the dynamic range
%   of A. If beta is less than 1, the amplitude of edges is reduced,
%   effectively compressing the dynamic range of A without affecting
%   details. If beta is greater than 1, the dynamic range of A is expanded.
%   If beta is equal to 1, the dynamic range of A is left unchanged.
%   If beta is omitted, then its value is assumed to be 1.
%
%   A must be grayscale or RGB and can be of class single, uint8, uint16,
%   int8 or int16. sigma must be non-negative. Although sigma can be
%   unbounded (albeit finite), for uint8, uint16, int8 or int16 images and
%   for single images defined over [0,1], sigma should be in [0,1]. alpha
%   must be positive. Typical values of alpha are in the range [0.01,10].
%   beta must be non-negative. Typical values of beta are in the range
%   [0,5].
%
%   B = locallapfilt(___, Name, Value, ...) filters the image using
%   name-value pairs to control advanced aspects of the filter. Parameter
%   names can be abbreviated. Parameters include:
%
%     'ColorMode'          - String or character vector with value either
%                            'luminance' or 'separate'. For RGB images, 
%                            if set to 'luminance', A is converted to 
%                            grayscale before filtering and color is 
%                            reintroduced after filtering, which changes 
%                            the contrast of A without affecting colors. 
%                            If set to 'separate', each color channel is 
%                            filtered independently. Grayscale images are 
%                            not affected by this parameter.
%
%                            Default: 'luminance'.
%
%     'NumIntensityLevels' - String, character vector or numeric scalar 
%                            specifying the number of intensity samples 
%                            in the dynamic range of A. 
%                            A higher number of samples gives results
%                            closer to exact Local Laplacian Filtering.
%                            A lower number increases the execution speed.
%                            Typical values are in the range [10,100]. If
%                            set to 'auto', the number of intensity levels
%                            is chosen automatically to balance quality and
%                            speed based on other parameters of the filter.
%
%                            Default: 'auto'.
%
%   Class Support
%   -------------
%   A must be a real, non-sparse, M-by-N or M-by-N-by-3 matrix of one of
%   the following classes: uint8, uint16, int8, int16 or single.
%
%   References
%   ----------
%   [1] Paris, Sylvain, Samuel W. Hasinoff, and Jan Kautz. "Local
%   Laplacian filters: edge-aware image processing with a Laplacian
%   pyramid." ACM Trans. Graph. 30.4 (2011): 68.
%
%   [2] Aubry, Mathieu, et al. "Fast local laplacian filters: Theory and
%   applications." ACM Transactions on Graphics (TOG) 33.5 (2014): 167.
%
%   Example 1 - Increase the local contrast of an image
%   ---------------------------------------------------
%     % Import an RGB image
%     A = imread('peppers.png');
%
%     % Set parameters of the filter to increase details smaller than 0.4
%     sigma = 0.4;
%     alpha = 0.5;
%
%     % Use Fast Local Laplacian Filtering
%     B = locallapfilt(A, sigma, alpha);
%
%     % Display the original and filtered images side by side
%     imshowpair(A, B, 'montage')
%
%   Example 2 - Use 'NumIntensityLevels' to balance speed and quality
%   -----------------------------------------------------------------
%     % Local Laplacian Filtering is a computationally intensive
%     % algorithm. To speed up processing, LOCALLAPFILT approximates
%     % it by discretizing the intensity range into a number of
%     % samples defined by the 'NumIntensityLevels' parameter.
%
%     % Let's study how this parameter can be used to balance
%     % speed and quality. Import an RGB image and display it:
%     A = imread('trailer.jpg');
%     figure
%     imshow(A)
%     title('Original Image')
%
%     % For this image we will use a signma value to process the details
%     % and an alpha value to increase the contrast, effectively enhancing
%     % the local contrast of the image.
%     sigma = 0.2;
%     alpha = 0.3;
%
%     % Using fewer samples increases the execution speed, but can 
%     % produce visible artifacts, especially in areas of flat contrast.
%     % Time the function using only 20 intensity levels:
%     t_speed = timeit(@() locallapfilt(A, sigma, alpha, 'NumIntensityLevels', 20))
%
%     % Now process the image and display it:
%     B_speed = locallapfilt(A, sigma, alpha, 'NumIntensityLevels', 20);
%     figure
%     imshow(B_speed)
%     title(['Enhanced with 20 intensity levels in ' num2str(t_speed) ' sec'])
%
%     % A larger number of samples yields better looking results at the
%     % expense of more processing time.
%     % Time the function using 100 intensity levels:
%     t_quality = timeit(@() locallapfilt(A, sigma, alpha, 'NumIntensityLevels', 100))
%
%     % Process the image with 100 intensity levels and display it:
%     B_quality = locallapfilt(A, sigma, alpha, 'NumIntensityLevels', 100);
%     figure
%     imshow(B_quality)
%     title(['Enhancement with 100 intensity levels in ' num2str(t_quality) ' sec'])
%
%     % Try varying the number of intensity levels on your own images. Try
%     % also flattening the contrast (with alpha > 1). You will see that
%     % the optimal number of intensity levels is different for every image
%     % and varies with alpha. By default, LOCALLAPFILT uses a heuristic to
%     % balance speed and quality, but it cannot predict the best value for
%     % every image.
%
%   Example 3 - Use 'ColorMode' to boost the local color contrast of an image
%   -------------------------------------------------------------------------
%     % By default, LOCALLAPFILT preserves the colors of the image by
%     % processing the intensity channel. The 'ColorMode' parameter lets
%     % you process each color channel independently instead, which has the
%     % effect of boosting the color contrast.
%
%     % Import a color image, reduce its size, and display it:
%     A = imread('car2.jpg');
%     A = imresize(A, 0.25);
%     figure
%     imshow(A)
%     title('Original Image')
%
%     % Set the parameters of the filter to dramatically increase
%     % details smaller than 0.3 (out of a normalized range of 0 to 1).
%     sigma = 0.3;
%     alpha = 0.1;
%
%     % Let's compare the two different modes of color filtering. Process
%     % the image by filtering its intensity and by filtering each color
%     % channel separately:
%     B_luminance = locallapfilt(A, sigma, alpha);
%     B_separate  = locallapfilt(A, sigma, alpha, 'ColorMode', 'separate');
%
%     % Display the filtered images:
%     figure, imshow(B_luminance)
%     title('Enhanced by boosting the local luminance contrast')
%     figure, imshow(B_separate)
%     title('Enhanced by boosting the local color contrast')
%
%     % An equal amount of contrast enhancement has been applied to each
%     % image, but colors are more saturated when setting 'ColorMode' to
%     % 'separate'.
%
%   Example 4 - Perform edge-aware noise reduction
%   ----------------------------------------------
%     % LOCALLAPFILT, implementing an edge-aware filter, lets you enhance
%     % or smooth details while leaving greater intensity variations
%     % unchanged. In this example we perform noise reduction by smoothing
%     % the details of an image.
%
%     % Import an image and convert it to floating point so
%     % that we can more easily add noise artificially to it:
%     A = imread('pout.tif');
%     A = im2single(A);
%
%     % Add Gaussian noise with zero mean and 0.001 variance:
%     A_noisy = imnoise(A, 'gaussian', 0, 0.001);
%     psnr_noisy = psnr(A_noisy, A);
%     fprintf('The peak signal-to-noise ratio of the noisy image is %0.4f\n', psnr_noisy);
%
%     % Set the amplitude of the details to smooth:
%     sigma = 0.1;
%
%     % Set the amount of smoothing to apply:
%     alpha = 4.0;
%
%     % Apply the edge-aware filter:
%     B = locallapfilt(A_noisy, sigma, alpha);
%     psnr_denoised = psnr(B, A);
%     fprintf('The peak signal-to-noise ratio of the denoised image is %0.4f\n', psnr_denoised);
%
%     % We obtain an improvement in the PSNR of the image.
%     % Display all three images side by side:
%     figure
%     subplot(1,3,1), imshow(A), title('Original')
%     subplot(1,3,2), imshow(A_noisy), title('Noisy')
%     subplot(1,3,3), imshow(B), title('Denoised')
%
%   Example 5 - Smooth out details without affecting edges
%   ------------------------------------------------------
%     % Similarly to Example 4 above, LOCALLAPFILT can be used to erase
%     % details in an image while keeping strong edges intact. In this
%     % example we wash a car.
%
%     % Import the image, resize it and display it:
%     A = imread('car1.jpg');
%     A = imresize(A, 0.25);
%     figure
%     imshow(A)
%     title('Original Image')
%
%     % The car is dirty and covered in scrambles.
%     % Let's try to erase the scrambles on the body.
%
%     % Set the amplitude of the details to smooth:
%     sigma = 0.2;
%
%     % Set a large amount of smoothing to apply:
%     alpha = 5.0;
%
%     % When smoothing (alpha > 1), the filter produces high quality
%     % results with a small number of intensity levels. Set a small
%     % number of intensity levels to process the image faster:
%     numLevels = 16;
%
%     % Apply the filter:
%     B = locallapfilt(A, sigma, alpha, 'NumIntensityLevels', numLevels);
%
%     % Display the "clean" car:
%     figure
%     imshow(B)
%     title('After smoothing details')
%
%   See also LOCALCONTRAST, LOCALTONEMAP.

%   Copyright 2016-2017 The MathWorks, Inc.

inputs = parseInputs(varargin{:});

input = inputs.A;
sigma = inputs.sigma;
alpha = inputs.alpha;
beta  = inputs.beta;
processLuminance   = inputs.ProcessLuminance;
numIntensityLevels = inputs.NumIntensityLevels;

output = llfmex(input, sigma, alpha, beta, numIntensityLevels, ...
                processLuminance);

%--------------------------------------------------------------------------
function inputs = parseInputs(varargin)

narginchk(3,10);

% Convert string inputs to character vectors.
args = matlab.images.internal.stringToChar(varargin);

% Parse inputs with basic validation
parser = inputParser();
parser.FunctionName = mfilename;

% A
validateInput = @(x) validateattributes(x, ...
    {'single','uint8','uint16','int8','int16'}, ...
    {'real','nonsparse','nonempty'}, ...
    mfilename,'A',1);
parser.addRequired('A', validateInput);

% sigma is expected non-negative
validateSigma = @(x) validateattributes(x, ...
    {'numeric'}, ...
    {'scalar','real','nonnegative','finite','nonsparse','nonempty'}, ...
    mfilename,'sigma',2);
parser.addRequired('sigma', validateSigma);

% alpha is expected positive
validateAlpha = @(x) validateattributes(x, ...
    {'numeric'}, ...
    {'scalar','real','positive','finite','nonsparse','nonempty'}, ...
    mfilename,'alpha',3);
parser.addRequired('alpha', validateAlpha);

% Optional beta parameter
defaultBeta = 1;
% beta is expected non-negative
validateBeta = @(x) validateattributes(x, ...
    {'numeric'}, ...
    {'scalar','real','nonnegative','finite','nonsparse','nonempty'}, ...
    mfilename,'beta',4);
parser.addOptional('beta', ...
    defaultBeta, ...
    validateBeta);

% NameValue 'NumIntensityLevels'
defaultNumIntensityLevels = 'auto';
parser.addParameter('NumIntensityLevels', ...
    defaultNumIntensityLevels, ...
    @validateNumIntensityLevels);

% NameValue 'ColorMode'
defaultColorMode = 'luminance';
% expected string 'luminance' or 'separate'
validateColorMode = @(x) validateattributes(x, ...
    {'char'}, ...
    {}, ...
    mfilename,'ColorMode');
parser.addParameter('ColorMode', ...
    defaultColorMode, ...
    validateColorMode);

parser.parse(args{:});
inputs = parser.Results;

% Post-processing and additional validation

% A must be MxN grayscale or MxNx3 RGB
validColorImage = (ndims(inputs.A) == 3) && (size(inputs.A,3) == 3);
if ~(ismatrix(inputs.A) || validColorImage)
    error(message('images:validate:invalidImageFormat','A'));
end

inputs.sigma = single(inputs.sigma);
inputs.alpha = single(inputs.alpha);
inputs.beta  = single(inputs.beta);

% Deal with ('NumIntensityLevels','auto')
if ischar(inputs.NumIntensityLevels)
    validatestring(inputs.NumIntensityLevels, ...
        {'auto'}, mfilename, 'NumIntensityLevels');
    inputs.NumIntensityLevels = getAutoNumIntensityLevels(inputs.alpha);
end
inputs.NumIntensityLevels = int32(inputs.NumIntensityLevels);

inputs.ColorMode = validatestring( ...
    inputs.ColorMode, ...
    {'luminance','separate'}, ...
    mfilename, 'ColorMode');
inputs.ProcessLuminance = strcmp(inputs.ColorMode, 'luminance');

%--------------------------------------------------------------------------
function TF = validateNumIntensityLevels(x)

if ~ischar(x)
    validateattributes(x, ...
        {'numeric'}, ...
        {'scalar','real','positive','integer', ...
        'finite','nonsparse','nonempty'}, ...
        mfilename,'NumIntensityLevels');
end

TF = true;

%--------------------------------------------------------------------------
function numIntensityLevels = getAutoNumIntensityLevels(alpha)

if alpha < 0.1
    % for strong contrast increase, use many intensity levels
    % to increase the quality of the output image
    numIntensityLevels = 50;
elseif alpha < 0.9
    % Progressively increase the number of intensity levels
    % from 16 to 50 as we strengthen the amount of details increase
    numIntensityLevels = round(((50*0.9-16*0.1) - (50-16)*alpha)/(0.9-0.1));
else
    % for a small contrast increase or any kind of smoothing
    % a low number of intensity levels is enough
    numIntensityLevels = 16;
end
