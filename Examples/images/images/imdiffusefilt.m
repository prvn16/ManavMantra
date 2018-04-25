function I = imdiffusefilt(I, varargin)
%IMDIFFUSEFILT Anisotropic diffusion filtering of images.
%   B = imdiffusefilt(A) applies anisotropic diffusion filtering to the
%   grayscale (M-by-N) image A and returns the result in B.
%
%   B = imdiffusefilt(V) applies anisotropic diffusion filtering to the
%   3-D (M-by-N-by-K) volume V and returns the result in B.
%
%   B = imdiffusefilt(___, PARAM, VAL) changes the behavior of the
%   anisotropic diffusion algorithm using the following name-value pairs:
%
%     'GradientThreshold'       Scalar or vector threshold between the image
%                               gradient affected by noise and the actual
%                               edge. This value controls the conduction
%                               process, and the default value is 10% of
%                               the dynamic range of the image. Increasing
%                               this value smoothes the image more.
%
%     'NumberOfIterations'      Positive scalar value specifying the number
%                               of iterations used for the diffusion process.
%                               The default value is 5.
%
%     'Connectivity'            The number of neighborhood differences
%                               considered for the diffusion process.
%                               The value of connectivity must be 'maximal'
%                               (default) or 'minimal'. With maximal
%                               connectivity, 8 and 26 nearest neighborhood
%                               differences are considered for 2D and 3D
%                               images respectively. Minimal connectivity
%                               considers 4 and 6 nearest neighborhood
%                               differences for 2D and 3D images respectively.
%
%     'ConductionMethod'        The method used for diffusion, which may be
%                               'exponential' (default) or 'quadratic'.
%                               Exponential diffusion favors high contrast
%                               edges over low contrast ones. Quadratic
%                               diffusion favors wide regions over smaller
%                               ones.
%
%   Class Support
%   -------------
%   The input array A must be one of the following classes: uint8, int8, uint16,
%   int16, uint32, int32, single or double. It must be real and non-sparse.
%   Output image B is an array of the same size and type as A.
%
%   Example 1
%   ---------
%   % Perform edge-preserving smoothing
%
%   I = imread('cameraman.tif');
%   diffusedImage = imdiffusefilt(I);
%   figure, montage({I, diffusedImage});
%
%   Example 2
%   ---------
%   % Perform edge-aware noise reduction
%
%   A = imread('pout.tif');
%   noisyImage = imnoise(A, 'gaussian', 0, 0.001);
%   B = imdiffusefilt(noisyImage, 'GradientThreshold', 15, 'NumberOfIterations', 7);
%   figure, montage({noisyImage, B});
%
%   Example 3
%   ---------
%   % Perform edge-aware noise reduction on a 3D grayscale volume
%
%   volData = load ('mri');
%   vol = squeeze(volData.D);
%   noisyImage = imnoise(vol, 'gaussian', 0, 0.001);
%   diffusedImage = imdiffusefilt(noisyImage, 'NumberOfIterations', 3);
%
%   figure, montage(noisyImage, volData.map);
%   title('Noisy volume');
%
%   figure, montage(diffusedImage, volData.map);
%   title('Anisotropic diffusion filtered volume');
%
%
%   References
%   ---------
%   [1] P. Perona and J. Malik., "Scale-Space and Edge Detection Using
%       Anisotropic Diffusion", IEEE Trans. Pattern Anal. Mach. Intell.
%       12, 7 (July 1990), 629-639.
%   [2] Gerig, Guido, et al. "Nonlinear anisotropic filtering of MRI
%       data", IEEE Transactions on medical imaging 11.2 (1992), 221-232.
%
%   See also imguidedfilter, imbilatfilt, imdiffuseest, locallapfilt.

%   Copyright 2017-2018 The MathWorks, Inc.

[I, gradThresh, N, connectivity, conductionMethod] = parseInputs(I, varargin{:});
originalClass = class(I);
dim = ndims(I);
if numel(gradThresh)>1
    gradientThreshold = gradThresh;
else
    gradientThreshold = repmat(gradThresh, [1 N]);
end
if ~(isfloat(I))
    % convert to double if image is not float type
    I = double(I);
end
gradientThreshold = double(gradientThreshold);
if (dim == 2)
    I = diffusefilt2D(I, gradientThreshold, N, connectivity, conductionMethod);
elseif (dim == 3)
    I = diffusefilt3D(I, gradientThreshold, N, connectivity, conductionMethod);
end
I = cast(I, originalClass);
end

function I = diffusefilt2D(I, gradientThreshold, N, connectivity, conductionMethod)
% Compute nearest neighbor differences in different directions
for loopCount =1:N
    I = anisotropicDiffusion2D(I,gradientThreshold(loopCount), connectivity, conductionMethod);
end
end

function Ifilt = diffusefilt3D(I, gradientThreshold, N, connectivity, conductionMethod)
Ifilt = I;
dimZ = size(I,3);
dx = 1;
dy = 1;
dz = 1;
dd = sqrt(dx^2 + dy^2);
dzd = sqrt(dz^2 + dd^2);
dzy = sqrt(dz^2 + dy^2);
dzx = sqrt(dz^2 + dx^2);
for loopCount = 1:N
    I1 = padarray(Ifilt,[1 1 1],'replicate');
    for sliceXY = 1:dimZ
        paddedData3D = I1(:,:,sliceXY:sliceXY+2);
        data3D =  paddedData3D(2:end-1,2:end-1,2);
        switch connectivity
            case 'minimal'
                diffusionRate =  1/6;
                diffImgMiddle1 = paddedData3D(2:end-1,2:end-1,1) -data3D;
                diffImgNorth2 =  paddedData3D(1:end-2,2:end-1,2) -data3D;
                diffImgSouth2 =  paddedData3D(3:end,2:end-1,2) - data3D;
                diffImgEast2 = paddedData3D(2:end-1,3:end,2) - data3D;
                diffImgWest2 = paddedData3D(2:end-1,1:end-2,2) - data3D;
                diffImgMiddle3 = paddedData3D(2:end-1,2:end-1,3) - data3D;
                switch conductionMethod
                    % Conduction coefficients
                    case 'exponential'
                        conductCoeffMiddle1 = exp(-(abs(diffImgMiddle1)/gradientThreshold(loopCount)).^2);
                        conductCoeffNorth2 = exp(-(abs(diffImgNorth2)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouth2 = exp(-(abs(diffImgSouth2)/gradientThreshold(loopCount)).^2);
                        conductCoeffEast2 = exp(-(abs(diffImgEast2)/gradientThreshold(loopCount)).^2);
                        conductCoeffWest2 = exp(-(abs(diffImgWest2)/gradientThreshold(loopCount)).^2);
                        conductCoeffMiddle3 = exp(-(abs(diffImgMiddle3)/gradientThreshold(loopCount)).^2);
                    case 'quadratic'
                        conductCoeffMiddle1 = 1./(1+(abs(diffImgMiddle1)/gradientThreshold(loopCount)).^2);
                        conductCoeffNorth2 = 1./(1+(abs(diffImgNorth2)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouth2 = 1./(1+(abs(diffImgSouth2)/gradientThreshold(loopCount)).^2);
                        conductCoeffEast2 = 1./(1+(abs(diffImgEast2)/gradientThreshold(loopCount)).^2);
                        conductCoeffWest2 = 1./(1+(abs(diffImgWest2)/gradientThreshold(loopCount)).^2);
                        conductCoeffMiddle3 = 1./(1+(abs(diffImgMiddle3)/gradientThreshold(loopCount)).^2);
                end
                % Discrete PDE solution
                Ifilt(:, :, sliceXY)  = Ifilt(:, :, sliceXY) + diffusionRate * ((1/(dz^2)).* conductCoeffMiddle1.* diffImgMiddle1 + ...
                    (1/(dy^2)).* conductCoeffNorth2.* diffImgNorth2 + (1/(dy^2)).* conductCoeffSouth2.* diffImgSouth2 + ...
                    (1/(dx^2)).* conductCoeffEast2.* diffImgEast2 + (1/(dx^2)).* conductCoeffWest2.* diffImgWest2 + ...
                    (1/(dz^2)).* conductCoeffMiddle3.* diffImgMiddle3 );
            case 'maximal'
                diffusionRate =  1/26;
                diffImgNorth1 = paddedData3D(1:end-2,2:end-1,1) - data3D;
                diffImgSouth1 = paddedData3D(3:end,2:end-1,1) - data3D;
                diffImgEast1 = paddedData3D(2:end-1,3:end,1) - data3D;
                diffImgWest1 = paddedData3D(2:end-1,1:end-2,1) - data3D;
                diffImgMiddle1 = paddedData3D(2:end-1,2:end-1,1) - data3D;
                diffImgNorthWest1 = paddedData3D(1:end-2,1:end-2,1) - data3D;
                diffImgNorthEast1 = paddedData3D(1:end-2,3:end,1) - data3D;
                diffImgSouthWest1 = paddedData3D(3:end,1:end-2,1) - data3D;
                diffImgSouthEast1 = paddedData3D(3:end,3:end,1) - data3D;
                diffImgNorth2 =  paddedData3D(1:end-2,2:end-1,2) - data3D;
                diffImgSouth2 =  paddedData3D(3:end,2:end-1,2) - data3D;
                diffImgEast2 = paddedData3D(2:end-1,3:end,2) - data3D;
                diffImgWest2 = paddedData3D(2:end-1,1:end-2,2) - data3D;
                diffImgNorthWest2 = paddedData3D(1:end-2,1:end-2,2) - data3D;
                diffImgNorthEast2 = paddedData3D(1:end-2,3:end,2) - data3D;
                diffImgSouthWest2 = paddedData3D(3:end,1:end-2,2) - data3D;
                diffImgSouthEast2 = paddedData3D(3:end,3:end,2) - data3D;
                diffImgNorth3 = paddedData3D(1:end-2,2:end-1,3) - data3D;
                diffImgSouth3 = paddedData3D(3:end,2:end-1,3) - data3D;
                diffImgEast3 = paddedData3D(2:end-1,3:end,3) - data3D;
                diffImgWest3 = paddedData3D(2:end-1,1:end-2,3) - data3D;
                diffImgMiddle3 = paddedData3D(2:end-1,2:end-1,3) - data3D;
                diffImgNorthWest3 = paddedData3D(1:end-2,1:end-2,3) - data3D;
                diffImgNorthEast3 = paddedData3D(1:end-2,3:end,3) - data3D;
                diffImgSouthWest3 = paddedData3D(3:end,1:end-2,3) - data3D;
                diffImgSouthEast3 = paddedData3D(3:end,3:end,3) - data3D;
                
                switch conductionMethod
                    % Conduction coefficients
                    case 'exponential'
                        conductCoeffNorth1 = exp(-(abs(diffImgNorth1)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouth1 = exp(-(abs(diffImgSouth1)/gradientThreshold(loopCount)).^2);
                        conductCoeffEast1 = exp(-(abs(diffImgEast1)/gradientThreshold(loopCount)).^2);
                        conductCoeffWest1 = exp(-(abs(diffImgWest1)/gradientThreshold(loopCount)).^2);
                        conductCoeffNorthWest1 = exp(-(abs(diffImgNorthWest1)/gradientThreshold(loopCount)).^2);
                        conductCoeffNorthEast1 = exp(-(abs(diffImgNorthEast1)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouthWest1 = exp(-(abs(diffImgSouthWest1)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouthEast1 = exp(-(abs(diffImgSouthEast1)/gradientThreshold(loopCount)).^2);
                        conductCoeffMiddle1 = exp(-(abs(diffImgMiddle1)/gradientThreshold(loopCount)).^2);
                        conductCoeffNorth2 = exp(-(abs(diffImgNorth2)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouth2 = exp(-(abs(diffImgSouth2)/gradientThreshold(loopCount)).^2);
                        conductCoeffEast2 = exp(-(abs(diffImgEast2)/gradientThreshold(loopCount)).^2);
                        conductCoeffWest2 = exp(-(abs(diffImgWest2)/gradientThreshold(loopCount)).^2);
                        conductCoeffNorthWest2 = exp(-(abs(diffImgNorthWest2)/gradientThreshold(loopCount)).^2);
                        conductCoeffNorthEast2 = exp(-(abs(diffImgNorthEast2)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouthWest2 = exp(-(abs(diffImgSouthWest2)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouthEast2 = exp(-(abs(diffImgSouthEast2)/gradientThreshold(loopCount)).^2);
                        conductCoeffNorth3 = exp(-(abs(diffImgNorth3)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouth3 = exp(-(abs(diffImgSouth3)/gradientThreshold(loopCount)).^2);
                        conductCoeffEast3 = exp(-(abs(diffImgEast3)/gradientThreshold(loopCount)).^2);
                        conductCoeffWest3 = exp(-(abs(diffImgWest3)/gradientThreshold(loopCount)).^2);
                        conductCoeffMiddle3 = exp(-(abs(diffImgMiddle3)/gradientThreshold(loopCount)).^2);
                        conductCoeffNorthWest3 = exp(-(abs(diffImgNorthWest3)/gradientThreshold(loopCount)).^2);
                        conductCoeffNorthEast3 = exp(-(abs(diffImgNorthEast3)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouthWest3 = exp(-(abs(diffImgSouthWest3)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouthEast3 = exp(-(abs(diffImgSouthEast3)/gradientThreshold(loopCount)).^2);
                        
                    case 'quadratic'
                        conductCoeffNorth1 = 1./(1+(abs(diffImgNorth1)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouth1 = 1./(1+(abs(diffImgSouth1)/gradientThreshold(loopCount)).^2);
                        conductCoeffEast1 = 1./(1+(abs(diffImgEast1)/gradientThreshold(loopCount)).^2);
                        conductCoeffWest1 = 1./(1+(abs(diffImgWest1)/gradientThreshold(loopCount)).^2);
                        conductCoeffMiddle1 = 1./(1+(abs(diffImgMiddle1)/gradientThreshold(loopCount)).^2);
                        conductCoeffNorth2 = 1./(1+(abs(diffImgNorth2)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouth2 = 1./(1+(abs(diffImgSouth2)/gradientThreshold(loopCount)).^2);
                        conductCoeffEast2 = 1./(1+(abs(diffImgEast2)/gradientThreshold(loopCount)).^2);
                        conductCoeffWest2 = 1./(1+(abs(diffImgWest2)/gradientThreshold(loopCount)).^2);
                        conductCoeffNorth3 = 1./(1+(abs(diffImgNorth3)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouth3 = 1./(1+(abs(diffImgSouth3)/gradientThreshold(loopCount)).^2);
                        conductCoeffEast3 = 1./(1+(abs(diffImgEast3)/gradientThreshold(loopCount)).^2);
                        conductCoeffWest3 = 1./(1+(abs(diffImgWest3)/gradientThreshold(loopCount)).^2);
                        conductCoeffMiddle3 = 1./(1+(abs(diffImgMiddle3)/gradientThreshold(loopCount)).^2);
                        conductCoeffNorthWest1 = 1./(1+(abs(diffImgNorthWest1)/gradientThreshold(loopCount)).^2);
                        conductCoeffNorthEast1 = 1./(1+(abs(diffImgNorthEast1)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouthWest1 = 1./(1+(abs(diffImgSouthWest1)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouthEast1 = 1./(1+(abs(diffImgSouthEast1)/gradientThreshold(loopCount)).^2);
                        conductCoeffNorthWest2 = 1./(1+(abs(diffImgNorthWest2)/gradientThreshold(loopCount)).^2);
                        conductCoeffNorthEast2 = 1./(1+(abs(diffImgNorthEast2)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouthWest2 = 1./(1+(abs(diffImgSouthWest2)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouthEast2 = 1./(1+(abs(diffImgSouthEast2)/gradientThreshold(loopCount)).^2);
                        conductCoeffNorthWest3 = 1./(1+(abs(diffImgNorthWest3)/gradientThreshold(loopCount)).^2);
                        conductCoeffNorthEast3 = 1./(1+(abs(diffImgNorthEast3)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouthWest3 = 1./(1+(abs(diffImgSouthWest3)/gradientThreshold(loopCount)).^2);
                        conductCoeffSouthEast3 = 1./(1+(abs(diffImgSouthEast3)/gradientThreshold(loopCount)).^2);
                end
                % Discrete PDE solution
                Ifilt(:,:,sliceXY)  = Ifilt(:,:,sliceXY) + diffusionRate*((1/(dzy^2)).*conductCoeffNorth1.*diffImgNorth1 + ...
                    (1/(dzy^2)).*conductCoeffSouth1.*diffImgSouth1 + (1/(dzx^2)).*conductCoeffEast1.*diffImgEast1 + ...
                    (1/(dzx^2)).*conductCoeffWest1.*diffImgWest1 + (1/(dz^2)).*conductCoeffMiddle1.*diffImgMiddle1 + ...
                    (1/dzd^2).*conductCoeffNorthWest1.*diffImgNorthWest1 + (1/dzd^2).*conductCoeffNorthEast1.*diffImgNorthEast1+...
                    (1/dzd^2).*conductCoeffSouthWest1.*diffImgSouthWest1 + (1/dzd^2).*conductCoeffSouthEast1.*diffImgSouthEast1+...
                    (1/(dy^2)).*conductCoeffNorth2.*diffImgNorth2 + (1/(dy^2)).*conductCoeffSouth2.*diffImgSouth2 + ...
                    (1/(dx^2)).*conductCoeffEast2.*diffImgEast2 + (1/(dx^2)).*conductCoeffWest2.*diffImgWest2 + ...
                    (1/dd^2).*conductCoeffNorthWest2.*diffImgNorthWest2 + (1/dd^2).*conductCoeffNorthEast2.*diffImgNorthEast2+...
                    (1/dd^2).*conductCoeffSouthWest2.*diffImgSouthWest2 + (1/dd^2).*conductCoeffSouthEast2.*diffImgSouthEast2+...
                    (1/(dzy^2)).*conductCoeffNorth3.*diffImgNorth3 + (1/(dzy^2)).*conductCoeffSouth3.*diffImgSouth3 + ...
                    (1/(dzx^2)).*conductCoeffEast3.*diffImgEast3 + (1/(dzx^2)).*conductCoeffWest3.*diffImgWest3 +...
                    (1/(dz^2)).*conductCoeffMiddle3.*diffImgMiddle3 +(1/dzd^2).*conductCoeffNorthWest3.*diffImgNorthWest3 + ...
                    (1/dzd^2).*conductCoeffNorthEast3.*diffImgNorthEast3+(1/dzd^2).*conductCoeffSouthWest3.*diffImgSouthWest3 +...
                    (1/dzd^2).*conductCoeffSouthEast3.*diffImgSouthEast3);
                
        end
    end
end
end

function [im, gradientThreshold, N, connectivity, conductionMethod] = parseInputs(im, varargin)
% parsing inputs other than default
narginchk(1, 9);
isRGB = (ndims(im) == 3) && (size(im,3) == 3);
% persistent parser
parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.PartialMatching = true;
parser = inputParser();
validateattributes(im,...
    {'single', 'double', 'uint8', 'uint16','uint32','int8','int16','int32'},...
    {'real', 'nonsparse', 'nonempty'}, ...
    mfilename, 'im', 1);
parser.addParameter('GradientThreshold', 0.1*diff(getrangefromclass(im)), @checkgradientThreshold);
parser.addParameter('NumberOfIterations', [], @checkN);
parser.addParameter('Connectivity', 'maximal', @checkconnectivity);
parser.addParameter('ConductionMethod', 'exponential', @checkconductionMethodString);
parser.parse(varargin{:});
gradientThreshold = parser.Results.GradientThreshold;
N = parser.Results.NumberOfIterations;
connectivity = validatestring(parser.Results.Connectivity, {'maximal', 'minimal'}, ...
    mfilename, 'Connectivity');
conductionMethod = validatestring(parser.Results.ConductionMethod, {'exponential', 'quadratic'}, ...
    mfilename, 'ConductionMethod');
if(isRGB)
    warning(message('images:imdiffusefilt:unsupportedImageFormat'));
end
if (~(numel(gradientThreshold) > 1) && isempty(N))
    N = 5;
elseif ((numel(gradientThreshold) > 1) && isempty(N))
    N = numel(gradientThreshold);
end
if (numel(gradientThreshold) > 1) && (numel(gradientThreshold)~= N)
    error(message('images:imdiffusefilt:invalidGradientThresholdVector'))
end
end
function gth = checkgradientThreshold(gradientThreshold)
validateattributes(gradientThreshold, ...
    {'numeric'}, ...
    {'vector', 'real', 'nonnegative', '>', 0, 'nonsparse','finite','nonempty'}, ...
    mfilename, 'GradientThreshold');
gth = true;
end

function numIter = checkN(N)
validateattributes(N, ...
    {'numeric'}, ...
    {'scalar','real', 'nonnegative', '>', 0, 'nonsparse','integer'}, ...
    mfilename, 'NumberOfIterations');
numIter = true;
end

function tf = checkconductionMethodString(methodString)
validateattributes(methodString, ...
    {'char', 'string'},...
    {'scalartext'},...
    mfilename, 'ConductionMethod');
tf = true;
end

function tf = checkconnectivity(methodString)
validateattributes(methodString, ...
    {'char', 'string'},...
    {'scalartext'},...
    mfilename, 'Connectivity');
tf = true;
end