function blendedImage = blendexposure(varargin)
%BLENDEXPOSURE Create well-exposed image from images with different exposures.
%
%   E = BLENDEXPOSURE(I1, I2, ..., In) blends the grayscale or RGB images
%   I1, I2, ..., In, which have different exposures. E is a fused image
%   with a better overall exposure based on contrast, saturation and
%   well-exposedness weights that are computed per image.
%
%   [___] = BLENDEXPOSURE(___, PARAM, VAL) changes the creation of the
%   blended image E using following name-value pairs.
%
%       'Contrast'          The relative weight given to contrast when
%                           blending images. It must be scalar and in the range
%                           [0,1]. The default value is 1.
%
%       'Saturation'        The relative weight given to color saturation
%                           when blending images. It must be scalar and in
%                           the range [0,1]. The default value is 1.
%
%       'WellExposedness'   The relative weight during blending given to
%                           how well exposed the images are. It must be
%                           scalar and in the range [0,1]. The default
%                           value is 1. This factor is based on the
%                           divergence of the image's pixel intensities
%                           from a hypothetical "good" exposure.
%
%       'ReduceStrongLight' A logical value (default being true) that
%                           decides whether to suppress strong light sources
%                           from images.
%
%   Class Support
%   -------------   
%   I1, I2, ..., In supports uint8, uint16, double or single. Images must
%   be real, nonsparse, M-by-N-by-3 RGB or M-by-N grayscale images. All the
%   images must be of same class and same size. E is an array of the same size 
%   and class type as I1.
%
%   Example 1
%   ---------
%   % Blend images with different exposures that are already registered or
%   % were captured from a fixed camera with no moving objects in the
%   % scene.
%
%   I1 = imread('car_1.jpg');
%   I2 = imread('car_2.jpg');
%   I3 = imread('car_3.jpg');
%   I4 = imread('car_4.jpg');
%
%   figure; montage({I1, I2, I3, I4});
%
%   E = blendexposure(I1, I2, I3, I4);
%
%   figure; imshow(E);
%
%   Example 2
%   ---------
%   % Blend different exposure images without reduction of strong light sources.
%
%   I1 = imread('car_1.jpg');
%   I2 = imread('car_2.jpg');
%   I3 = imread('car_3.jpg');
%   I4 = imread('car_4.jpg');
%
%   figure; montage({I1, I2, I3, I4});
%
%   E = blendexposure(I1, I2, I3, I4, 'Contrast', 1, 'Saturation', 1, ...
%        'WellExposedness', 1, 'ReduceStrongLight', false);
%
%   figure; imshow(E);
%
%   Notes
%   -----
%   The contrast method finds weights using Laplacian filtering. Saturation
%   weights are computed via the standard deviation of each image.
%   Well-exposedness is determined by comparing parts of the image to a
%   Gaussian distribution with mu = 0.5 and sigma = 0.2. Strong light
%   reduction weights are computed as a mixture of the other three weights
%   multiplied by a Gaussian distribution with fixed mean and variance.
%
%   The weights are decomposed using Gaussian pyramid for seamless
%   blending with a Laplacian pyramid of the corresponding image, which
%   helps preserve scene details. In the absence of strong light source, if
%   ReduceStrongLight module is true then contrast of overall output image
%   reduces.
%
%   References
%   ----------
%   [1] T.Mertens, J. Kautz, and F. V. Reeth, Exposure fusion, Pacific
%   Graphics, 2007
%
%   See also IMREGMTB, MAKEHDR, TONEMAP, HDRREAD.

%   Copyright 2017 The MathWorks, Inc.

narginchk(2,inf);
[I, conExponent, satExponent, wellExpExponent, reduceStrongLight] = parseInputs(varargin{:});

originalClass = class(I{1});

if isfloat(I{1})
    % The algorithm assumes the input image is in [0,1]
    for i = 1:numel(I)
        I{i} = min(1, max(0, I{i}));
    end
else
    % Convert to single if image is not float type
    for i = 1:numel(I)
        I{i} = im2single(I{i});
    end
end

r = size(I{1}, 1);
c = size(I{1}, 2);

numImages = numel(I);

% Initialize weights
weights = ones(r, c, numImages, 'like', I{1});
conExponent = cast(conExponent, 'like', I{1});
satExponent = cast(satExponent, 'like', I{1});
wellExpExponent = cast(wellExpExponent, 'like', I{1});

% Check for gray or color image
numPlanes = size(I{1}, 3);
if (conExponent > 0)
    weights = weights.*contrast(I, numPlanes).^conExponent;
end
if (satExponent > 0)
    if numPlanes == 3
        weights = weights.*saturation(I).^satExponent;
    end
end
if (wellExpExponent > 0)
    weights = weights.*wellExposedness(I, numPlanes).^wellExpExponent;
end

% Reduce dominance of strong light source.
if reduceStrongLight
    weights = weights.*reduceStrongLightSource(I, numPlanes);
end

% To prevent divide by zero
weights = weights + 10^-12; % value is decided by author

% Normalize weights
weights = weights./repmat(sum(weights, 3),[1 1 numImages]);

% Compute number of pyramid levels
numLevels = floor(log2(min(r, c)));
imagePyramid = cell(numLevels, 1);

% Initialize output in pyramidal form
imagePyramid{1} = zeros(r, c, numPlanes);
for levels = 2:numLevels
    imagePyramid{levels} = zeros(ceil(size(imagePyramid{levels-1}, 1)/2),ceil(size(imagePyramid{levels-1} ,2)/2), numPlanes);
end

% multiresolution blending
for imgIdx = 1:numImages
    % construct gaussian pyramid for each weight
    weightsPyramid = gaussianPyramid(weights(:,:,imgIdx), numLevels);
    % construct laplacian pyramid for each image
    residualPyramid = laplacianPyramid(I{imgIdx}, numLevels);
    
    % blend weights and image in pyramidal way
    for thePyramid = 1:numLevels
        if numPlanes == 3
            theWeight = repmat(weightsPyramid{thePyramid}, [1 1 3]);
        else
            theWeight = weightsPyramid{thePyramid};
        end
        imagePyramid{thePyramid} = imagePyramid{thePyramid} + theWeight.*residualPyramid{thePyramid};
        
    end
    
end
blendedImage= reconstructLaplacianPyramid(imagePyramid);

% Convert exposure fused image back to input image class
blendedImage = convertToOriginalClass(blendedImage, originalClass);
end

function W = contrast(I, numPlanes)

% contrast measure
h = [0 -1 0;-1 4 -1;0 -1 0];  % laplacian filter
numImages = size(I, 2);
W = zeros(size(I{1},1), size(I{1},2), numImages);
for currentImage = 1:numImages
    if numPlanes ==3
        singleImage = rgb2gray(I{currentImage});
    else
        singleImage = I{currentImage};
    end
    W(:, :, currentImage) = abs(imfilter(singleImage, h, 'symmetric'));
    
end
end

function W = saturation(I)

% saturation measure
numImages = numel(I);
W = zeros(size(I{1},1), size(I{1},2), numImages);
for currentImage = 1:numImages
    % saturation is computed as the standard deviation of the color channels
    W(:, :, currentImage) = std(I{currentImage}, 1, 3);
end
end

function W = wellExposedness(I, numPlanes)

% well-exposedness measure
sigma = .2;
sigmaSq = sigma^2;
mu = .5;
W = weightDistribution(I, mu, sigmaSq, numPlanes);

end

function W = reduceStrongLightSource(I, numPlanes)
% To remove strong light region,  one more weight has been added. If we don't use
% this weights in exposure fusion than in night time or in day time bright
% light spots will dominate (e.g head light). If we use this weights, over all
% output will get marginally dark (but does not effect overall output much).

sigma = 0.1;
sigmaSq = sigma^2;
mu = 0.3;
W = weightDistribution(I, mu, sigmaSq, numPlanes);
end

function gassianWeights = weightDistribution(I, mu, sigmaSq, numPlanes)
numImages = size(I, 2);
gassianWeights = zeros(size(I{1}, 1), size(I{1}, 2), numImages);
for currentImage = 1:numImages
    if numPlanes == 3
        R = exp(-.5*(I{currentImage}(:, :, 1) - mu).^2/sigmaSq);
        G = exp(-.5*(I{currentImage}(:, :, 2) - mu).^2/sigmaSq);
        B = exp(-.5*(I{currentImage}(:, :, 3) - mu).^2/sigmaSq);
        gassianWeights(:, :, currentImage) = R.*G.*B;
    else
        grayChannel = exp(-.5*(I{currentImage} - mu).^2/sigmaSq);
        gassianWeights(:, :, currentImage) = grayChannel;
    end
end

end

function thePyramid = gaussianPyramid(originalImage, numLevels)
% Gaussian pyramid

thePyramid = cell(numLevels, 1);
thePyramid{1} = originalImage;
for thisLevel = 2:numLevels
    reducedImage = impyramid(thePyramid{thisLevel-1}, 'reduce');
    thePyramid{thisLevel} = reducedImage;
end
end

function thePyramid = laplacianPyramid(orignalImage, numLevels)
%Laplacian pyramid

currentPyrmid = orignalImage;
thePyramid = cell(numLevels, 1);
for thisLevel = 1:numLevels-1
    reducedImage = impyramid(currentPyrmid, 'reduce');
    
    upSampledImage =  upSample(currentPyrmid, reducedImage);
    thePyramid{thisLevel} =  currentPyrmid - upSampledImage;
    currentPyrmid = reducedImage;
end
thePyramid{numLevels} = currentPyrmid;
end

function R = reconstructLaplacianPyramid(imagePyramid)

numLevels = length(imagePyramid);
% start with low pass residual
R = imagePyramid{numLevels};
for thisLevel = numLevels - 1 : -1 : 1
    % upsample, and add to current level
    upSampledImg = upSample(imagePyramid{thisLevel}, R);
    R = imagePyramid{thisLevel} + upSampledImg;
end
end

function R = upSample(originalImg, downsampledImg)

odd = 2*size(downsampledImg) - size(originalImg);
filter = [0.0625   0.25   0.375   0.25   0.0625]; % Standard low pass filter
f = filter'.*filter; % upsampling filter
% image padding with a 1-pixel border
downsampledImg = padarray(downsampledImg, [1 1 0], 'symmetric');
r = 2*size(downsampledImg, 1);
c = 2*size(downsampledImg, 2);
R = zeros(r, c, size(downsampledImg, 3));
R(1:2:r, 1:2:c, :) = 4*downsampledImg; % increase size 2 times

R = imfilter(R, f, 'symmetric');
% remove the border
R = R(3:r-2-odd(1), 3:c-2-odd(2), :);
end

function [im, contrast, saturation, wellExposedness, reduceBrightLight] = parseInputs(varargin)
parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.PartialMatching = true;

im = {};
imageCount = 0;

chkImg = varargin{1};
validateattributes(chkImg, {'single', 'double', 'uint8', 'uint16'},...
    {'nonsparse', 'real'}, mfilename, 'chkImg', 1);

if size(chkImg, 1) == 1 || size(chkImg, 2) == 1
    error(message('images:blendexposure:incorrectSize'));
end

if ndims(chkImg) >= 4 || (size(chkImg,3) ~= 3 && size(chkImg,3) ~= 1)
    error(message('images:validate:invalidImageFormat', 'im'));
end
originalClass = class(chkImg);
for ind = 1:numel(varargin)
    if ~(isnumeric(varargin{ind}) || iscell(varargin{ind}))
        break;
    end
    im{end+1} = varargin{ind}; %#ok<AGROW>
    if ~strcmp(originalClass, class(varargin{ind}))
        error(message('images:blendexposure:invalidInputClass'));
    end
    imageCount = imageCount+1;
end

pvArgs = {};
if ind <= numel(varargin)
    if ischar(varargin{ind}) || isstring(varargin{ind})
        pvArgs = varargin(ind:end);
    else
        pvArgs = varargin(ind+1:end);
    end
    
end

if imageCount == 1
    error(message('images:blendexposure:insufficientInputImages'));
end
% If one image is passed as a input
if length(pvArgs) > 8
    error(message('images:blendexposure:tooManyInputArguments'));
end

chkSize = size(chkImg);
for i = 1:numel(im)
    validateattributes(im{i},...
        {'single', 'double', 'uint8', 'uint16'},...
        {'real', 'nonsparse', 'nonempty', 'size', chkSize}, ...
        mfilename, 'im', i);
    
end

parser.addParameter('Contrast', 1, @(val) checkWeightParameter(val, 'Contrast'));
parser.addParameter('Saturation', 1, @(val) checkWeightParameter(val, 'Saturation'));
parser.addParameter('WellExposedness', 1, @(val) checkWeightParameter(val, 'WellExposedness'));
parser.addParameter('ReduceStrongLight', 1, @checkStrongLightString);
parser.parse(pvArgs{:});

contrast = parser.Results.Contrast;
saturation = parser.Results.Saturation;
wellExposedness = parser.Results.WellExposedness;
reduceBrightLight = parser.Results.ReduceStrongLight;

end

function tf = checkWeightParameter(val, pname)

validateattributes(val, {'double', 'single'}, {'nonsparse', 'real', 'scalar', ...
    'finite', 'nonnegative', '<=', 1},...
    mfilename, pname);
tf = true;

end

function tf = checkStrongLightString(ReduceStrongLight)
validateattributes(ReduceStrongLight, ...
    {'logical'},...
    {'real'},...
    mfilename, 'ReduceStrongLight');

tf = true;
end

function B = convertToOriginalClass(B, OriginalClass)

if strcmp(OriginalClass, 'uint8')
    B = im2uint8(B);
elseif strcmp(OriginalClass, 'uint16')
    B = im2uint16(B);
elseif strcmp(OriginalClass, 'single')
    B = im2single(B);
    B = min(1,  max(0, B));
else
    %  double
    B = min(1, max(0, B));
end
end
