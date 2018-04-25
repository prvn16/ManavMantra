function B = chromadapt(varargin)
%CHROMADAPT Adjust the color balance of RGB images with chromatic adaptation
%
%   B = CHROMADAPT(A,illuminant) adjusts the color balance of sRGB image
%   A according to the scene illuminant. The illuminant is expected to be
%   in the same color space as the input image.
%
%   B = CHROMADAPT(___,Name,Value,...) specifies additional options as
%   name-value pairs:
%
%     'ColorSpace'  -  Color space of the input image and illuminant:
%                      'srgb' (default) | 'adobe-rgb-1998' | 'linear-rgb'
%
%                      Use this parameter if you wish to adjust the color
%                      balance of an RGB image whose intensities are
%                      linear.
%
%                      Default: 'srgb'
%
%     'Method'      -  Type of chromatic adaptation method to be employed:
%
%                        'bradford'  -  Scaling in the Bradford cone
%                                       response model (default).
%
%                        'vonkries'  -  Scaling in the von Kries cone
%                                       response model.
%
%                        'simple'    -  Simple scaling of the RGB values
%                                       in A by the illuminant.
%
%   Class Support
%   -------------
%   A must be a real, non-sparse, M-by-N-by-3 RGB image of one
%   of the following classes: uint8, uint16, single or double.
%
%   Note
%   ----
%   The color balancing process implemented in this function, also called
%   chromatic adaptation, consists in scaling the colors of the input image
%   in a certain color space or representation. The Bradford and von Kries
%   methods respectively transform the input image from RGB into the
%   Bradford and von Kries cone response domains, in which the colors are
%   scaled by the (transformed) input illuminant. The 'simple' method
%   scales the colors of the input RGB image by the illuminant without
%   transforming from RGB to another color space.
%
%   Reference
%   ---------
%   Bruce Lindbloom, Chromatic Adaptation,
%   http://www.brucelindbloom.com/Eqn_ChromAdapt.html
%
%   Example 1
%   ---------
%   Correct the color balance of an image by specifying a gray pixel
%
%     % Read an image with a strong yellow color cast and display it.
%     A = imread('hallway.jpg');
%     figure
%     imshow(A)
%     title('Original Image')
%
%     % Pick a pixel in the image which should look white or gray.
%     x = 2800;
%     y = 1000;
%     gray_val = [A(y,x,1) A(y,x,2) A(y,x,3)];
%
%     % Use the selected color as reference for the scene illumination and
%     % correct the white balance of the image.
%     B = chromadapt(A,gray_val);
%
%     % Display the corrected image.
%     figure
%     imshow(B)
%     title('White Balanced Image')
%
%   Example 2
%   ---------
%   Automatic White Balance
%
%     % Automatic White Balance algorithms try to preserve the perceived
%     % color of objects under varying light conditions. They do so in two
%     % steps:
%     %   1) Estimate the scene illumination, i.e., the color of the light.
%     %   2) Correct the color balance by chromatic adaptation.
%
%     % Read an image with an incorrect white balance.
%     A = imread('foosball.jpg');
%
%     % Most illuminant estimation algorithms assume a linear relationship
%     % between the response of the imaging sensor and pixel intensities.
%     % However, the relationship between the luminance of pixels on a
%     % display device and the input voltage is not linear; it follows a
%     % power curve with an exponent gamma typically between 2.2 and 2.6.
%     % For this reason, images stored in files such as JPEG have been
%     % gamma-corrected so that they look correct when displayed on a
%     % monitor. Before applying an illuminant estimation algorithm, we
%     % must undo the gamma correction by linearizing the RGB values.
%     A_linear = rgb2lin(A);
%
%     % Step 1: Use the White Patch illuminant estimation algorithm.
%     illuminant_linear = illumwhite(A_linear);
%
%     % Convert the estimated illuminant back to sRGB so that the input
%     % image A and the illuminant are in the same color space.
%     illuminant = lin2rgb(illuminant_linear);
%
%     % Step 2: Correct the color balance.
%     B = chromadapt(A,illuminant);
%
%     % Display the original and corrected images.
%     figure
%     imshowpair(A,B,'montage')
%     title('AWB using White Patch')
%
%   Example 3
%   ---------
%   Working with images in camera linear RGB space
%
%     % Open an image file containing minimally processed
%     % linear RGB intensities.
%     A = imread('foosballraw.tiff');
%
%     % The image data is the raw sensor data after correcting the black
%     % level and scaling to 16 bits per pixel. Interpolate the intensities
%     % to reconstruct color. The Color Filter Array pattern is RGGB.
%     A = demosaic(A,'rggb');
%
%     % The image has a ColorChecker Chart in the scene. Pick a pixel on
%     % one of the neutral patches of the chart to get the color of the
%     % ambient light.
%     x = 1510;
%     y = 1250;
%     light_color = [A(y,x,1) A(y,x,2) A(y,x,3)];
%
%     % Correct the color balance of the image.
%     % Use the 'ColorSpace' option to specify that the image and the
%     % illuminant are expressed in linear RGB.
%     B = chromadapt(A,light_color,'ColorSpace','linear-rgb');
%
%     % Display the original and corrected images.
%     % Because the images are in linear RGB, they should be gamma
%     % corrected in order to be displayed correctly on the screen.
%     A_sRGB = lin2rgb(A);
%     B_sRGB = lin2rgb(B);
%
%     figure
%     imshowpair(A_sRGB,B_sRGB,'montage')
%     title('Original and White Balanced Images')
%
%   See also WHITEPOINT.

%   Copyright 2016 The MathWorks, Inc.

inputs = parseInputs(varargin{:});

% Normalize illuminant so that Y=1
% This prevents changing the overall brightness of the scene.
illuminant_xyz = rgb2xyz(inputs.illuminant, ...
    'ColorSpace', inputs.ColorSpace);
illuminant_xyz(illuminant_xyz == 0) = eps(class(illuminant_xyz));
illuminant_xyz = illuminant_xyz / illuminant_xyz(2);

if strcmp(inputs.Method, 'simple')
    % Scale in floating point
    if isa(inputs.A,'double')
        convert = @(x) x;
    else
        convert = @im2single;
    end
    B = convert(inputs.A);
    
    % Convert the normalized illuminant back to RGB
    illuminant = xyz2rgb(illuminant_xyz, ...
        'ColorSpace', inputs.ColorSpace, ...
        'OutputType', class(B));
    
    % Simple scaling of the RGB values
    % Note: if illuminant has a zero value, this is undefined
    illuminant = abs(illuminant);
    illuminant(illuminant == 0) = eps(class(illuminant));
    B = B ./ reshape(illuminant, [1 1 3]);
    
    % Convert back to the right type
    convert = str2func(['im2' class(inputs.A)]);
    B = convert(B);
else
    % Bradford and von Kries methods
    C = makecform('adapt', ...
        'WhiteStart', double(illuminant_xyz), ...
        'WhiteEnd', whitepoint('d65'), ...
        'AdaptModel', inputs.Method);
    
    A_XYZ = rgb2xyz(inputs.A, ...
        'WhitePoint', 'd65', ...
        'ColorSpace', inputs.ColorSpace);
    
    B_XYZ = applycform(double(A_XYZ), C); % only works in double
    
    B = xyz2rgb(B_XYZ, ...
        'WhitePoint', 'd65', ...
        'ColorSpace', inputs.ColorSpace, ...
        'OutputType', class(inputs.A));
end

%--------------------------------------------------------------------------
function inputs = parseInputs(varargin)

narginchk(2,6);

parser = inputParser();
parser.FunctionName = mfilename;

% A
validateImage = @(x) validateattributes(x, ...
    {'single','double','uint8','uint16'}, ...
    {'real','nonsparse','nonempty'}, ...
    mfilename,'A',1);
parser.addRequired('A', validateImage);

% illuminant
validateIlluminant = @(x) validateattributes(x, ...
    {'single','double','uint8','uint16'}, ...
    {'real','nonsparse','nonempty','nonnan','finite','vector','numel',3}, ...
    mfilename,'illuminant',2);
parser.addRequired('illuminant', validateIlluminant);

validateStringInput = @(x,name) validateattributes(x, ...
    {'char','string'}, ...
    {'scalartext'}, ...
    mfilename, name);

% NameValue 'ColorSpace': 'srgb', 'adobe-rgb-1998' or 'linear-rgb'
validColorSpaces = {'srgb','adobe-rgb-1998','linear-rgb'};
defaultColorSpace = validColorSpaces{1};
validateColorSpace = @(x) validateStringInput(x,'ColorSpace');
parser.addParameter('ColorSpace', ...
    defaultColorSpace, ...
    validateColorSpace);

% NameValue 'Method': 'bradford', 'vonkries' or 'simple'
validMethods = {'bradford','vonkries','simple'};
defaultMethod = validMethods{1};
validateMethod = @(x) validateStringInput(x,'Method');
parser.addParameter('Method', ...
    defaultMethod, ...
    validateMethod);

parser.parse(varargin{:});
inputs = parser.Results;

% shape illuminant as a row vector
inputs.illuminant = inputs.illuminant(:)';

% Additional validation

% A must be a MxNx3 RGB image
validColorImage = (ndims(inputs.A) == 3) && (size(inputs.A,3) == 3);
if ~validColorImage
    error(message('images:validate:invalidRGBImage','A'));
end

% illuminant cannot be black [0 0 0]
if isequal(inputs.illuminant, [0 0 0])
    error(message('images:awb:illuminantCannotBeBlack'));
end

inputs.ColorSpace = validatestring( ...
    inputs.ColorSpace, ...
    validColorSpaces, ...
    mfilename, 'ColorSpace');

inputs.Method = validatestring( ...
    inputs.Method, ...
    validMethods, ...
    mfilename, 'Method');
