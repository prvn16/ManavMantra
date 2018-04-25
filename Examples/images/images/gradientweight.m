function W = gradientweight(varargin)
%GRADIENTWEIGHT Calculate weights for image pixels based on image gradient.
%
%   W = gradientweight(I) computes pixel weight for each pixel in image I
%   based on the gradient magnitude at that pixel, and returns the weights
%   in the array W, which is the same size as input image I. The output
%   weight of a pixel is inversely related to the gradient values at the
%   pixel location, so that for pixels with small gradient magnitude
%   (smooth regions), output weight is large, and for pixels with large
%   gradient magnitude (such as on the edges), output weight is small.
%
%   W = gradientweight(I, SIGMA) uses sigma as the standard deviation for
%   the derivative of gaussian kernel that is used for computing image
%   gradient. If SIGMA is not specified, default value of 1.5 is used.
%
%   W = gradientweight(___, Name, Value, ...) returns the weight array W
%   using name-value pairs to control aspects of weight computation.
%   Parameter names can be abbreviated.
% %
%   Parameters include:
% 
%   'RolloffFactor' - Positive scalar, P, that controls how fast the output
%                     weight falls as the function of gradient magnitude.
%                     High value of this parameter means that the output
%                     weight values will fall off sharply at the edges of
%                     smooth regions, whereas low value of this parameter
%                     would allow a more gradual falloff at the edges.
%                     Value in the range [0.5 4] are useful for this
%                     parameter. Default value is 3.
% 
%   'WeightCutoff'  - Positive scalar, K in the range [1e-3 1]. This 
%                     parameter puts a hard threshold on the weight values,
%                     and strongly suppresses any weight values less than K
%                     by setting them to a small constant value (1e-3).
%                     When the output weight array W is used for Fast
%                     Marching Method based segmentation (as input to
%                     IMSEGFMM), this parameter can be useful in improving
%                     the accuracy of the segmentation output. Default
%                     value is 0.25.
%
%   Class Support 
%   ------------- 
%   The input image I must be of one of the following classes: uint8, int8,
%   uint16, int16, uint32, int32, single, or double. It must be nonsparse.
%   SIGMA is a numeric scalar. Output array W is a an array of the same
%   size as I and class double, unless I is of class single in which case W
%   is also of class single.
%
%   Notes
%   -----
%   1. Double-precision floating point operations are used for internal
%      computations for all classes of I, except when I is of class single
%      in which case single-precision floating point operations are used
%      internally.
%      
%   Example 1
%   ---------
%   This example segments an object in the image using Fast Marching Method
%   based on the weights derived from grayscale intensity difference from
%   user-selected seed point(s).
%
%     I = imread('coins.png');
%     imshow(I)
%     title('Original Image')
% 
%     % Compute weights based on image gradient
%     sigma = 1.5;
%     W = gradientweight(I, sigma, 'RolloffFactor', 3, 'WeightCutoff', 0.25);
% 
%     % Select a seed location
%     R = 70; C = 216;
%     hold on; 
%     plot(C, R, 'r.', 'LineWidth', 1.5, 'MarkerSize',15);
% 
%     % Segment the image using the weights
%     thresh = 0.1;
%     [BW, D] = imsegfmm(W, C, R, thresh);
%     figure, imshow(BW)
%     title('Segmented Image')
%     hold on; 
%     plot(C, R, 'r.', 'LineWidth', 1.5, 'MarkerSize',15);
%     
%     % Geodesic distance matrix D can be thresholded using different 
%     % thresholds to get different segmentation results. 
%     figure, imshow(D)
%     title('Geodesic Distances')
%     hold on; 
%     plot(C, R, 'r.', 'LineWidth', 1.5, 'MarkerSize',15);
%
%   See also GRAYDIFFWEIGHT, GRAYDIST, IMSEGFMM.

%   Copyright 2014-2017 The MathWorks, Inc.

narginchk(1,6);

varargin = matlab.images.internal.stringToChar(varargin);

[I, sigma, rolloffFactor, weightCutoff] = parse_inputs(varargin{:});

if isinteger(I)
    I = double(I);
end
if isempty(I)    
    W = I;
    return;
end

if ismatrix(I)
    W = images.internal.imgradientdog(I,sigma);
else
    W = images.internal.imgradientdog3(I,sigma);
end

[W, minW, maxW] = images.internal.imlinscale(W);

floorOfW = 1e-3;
if ((maxW - minW) <= eps(maxW))
    % Constant intensity
    W = ones(size(I),'like',I);    
else
    W = W.^(1./rolloffFactor);
    W = (1 - W)./(1 + W);
    W(W < weightCutoff) = floorOfW;
end

end

function [I, sigma, rolloffFactor, weightCutoff] = parse_inputs(varargin)

parser = inputParser;

parser.addRequired('I', @validateImage);
parser.addOptional('sigma', 1.5, @validateSigma);
parser.addParameter('RolloffFactor',3, @validateRollOffFactor);
parser.addParameter('WeightCutoff',0.25, @validateWeightCutoff);

parser.parse(varargin{:});
res = parser.Results;

I = res.I;
rolloffFactor = double(res.RolloffFactor);
weightCutoff = double(res.WeightCutoff);
sigma = double(res.sigma);

nDimsI = ndims(I);
numelSigma = numel(sigma);

if numelSigma > nDimsI
    error(message('images:validate:invalidOptionalArgSize','sigma'));
end

switch (nDimsI)
            
    case 2
        if(numelSigma == 1)
            sigma = [sigma sigma];
        elseif (numelSigma == 2)
            sigma  = sigma;  
        end
        
    case 3
        if(numelSigma == 1) 
            sigma = [sigma sigma sigma];
        elseif (numelSigma == 2)
            error(message('images:validate:invalidOptionalArgSize','sigma'));  
        elseif (numelSigma == 3)
            sigma  = sigma;   
        end
        
    otherwise
        
end
    


end

function tf = validateImage(I)

    validImageTypes = {'uint8','int8','uint16','int16','uint32','int32', ...
    'single','double'};
    validateattributes(I,validImageTypes,{'nonsparse','real','3d'},mfilename,'I',1);
    tf = true;
end

function tf = validateSigma(sigma)

    validateattributes(sigma,{'numeric'},{'positive','finite', ...
        'real', 'nonempty'}, mfilename,'sigma',2);
    tf = true;
end

function tf = validateRollOffFactor(rolloffFactor)

    validateattributes(rolloffFactor,{'numeric'},{'positive', ...
                    'finite', 'real', 'nonempty','scalar'}, mfilename, ...
                    'RolloffFactor');
    tf = true;
end


function tf = validateWeightCutoff(weightCutoff)

    validateattributes(weightCutoff,{'numeric'},{'nonsparse', ...
                    'real','scalar','nonempty','nonnan','>=',1e-3,'<=',1}, ...
                    mfilename, 'WeightCutoff');
    tf = true;
end