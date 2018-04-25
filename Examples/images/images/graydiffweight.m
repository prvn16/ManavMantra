function W = graydiffweight(varargin)
%GRAYDIFFWEIGHT Calculate weights for image pixels based on grayscale intensity difference.
%
%   W = graydiffweight(I, refGrayVal) computes the pixel weight for each
%   pixel in image I based on the absolute value of the difference between
%   the grayscale intensity of the pixel and the reference grayscale
%   intensity specified by refGrayVal, which is a scalar. The weights
%   are returned in the array W, which is the same size as input image I.
%   The output weight of a pixel is inversely related to the absolute value
%   of the grayscale intensity difference at the pixel location, so that
%   for pixels with small difference (regions with intensity close to
%   refGrayVal), output weight is large, and for pixels with large
%   difference (regions with intensity very different from refGrayVal),
%   output weight is small. I can be a 2-D image or a 3-D volume.
%
%   W = graydiffweight(I, MASK), where MASK is a logical image of the same
%   size as I, computes the weights using average grayscale intensity of
%   all the pixels in I that are marked as logical true in MASK as the
%   reference grayscale intensity. I can be a 2-D image or a 3-D volume.
%
%   W = graydiffweight(I, C, R), computes the weights using average
%   grayscale intensity of pixel locations specified by C and R. C and R
%   are vectors containing the column and row indices of the seed pixel
%   locations. C and R must contain values which are valid pixel indices in
%   I.
%
%   W = graydiffweight(V, C, R, P) computes the weights using average
%   intensity of pixel locations specified by C, R and P. C, R and P are
%   vectors containing the column, row and plane indices of the seed pixel
%   locations. C, R and P must contain values which are valid pixel indices
%   in volume V.
%
%   W = graydiffweight(___, Name, Value, ...) returns the weight array W
%   using name-value pairs to control aspects of weight computation.
%   Parameter names can be abbreviated.
%
%   Parameters include:
%
%   'RolloffFactor'     - Positive scalar, P, that controls how fast the
%                         output weight falls as the function of absolute
%                         difference between an intensity and the reference
%                         grayscale intensity. High value of this parameter
%                         means that the output weight values will fall off
%                         sharply for intensities that are very different
%                         from reference grayscale intensity, whereas low
%                         value of this parameter would allow a more
%                         gradual falloff. Value in the range [0.5 4] are
%                         typically found to be useful for this parameter.
%                         Default value is 0.5.
%
%   'GrayDifferenceCutoff' - Non-negative scalar, K. This parameter puts a
%                         hard threshold on the absolute grayscale
%                         intensity difference values, and strongly
%                         suppresses the output weight value for any pixel
%                         whose absolute grayscale intensity difference
%                         from the reference grayscale intensity is greater
%                         than K by assigning them the smallest weight
%                         value. When the output weight array W is used for
%                         Fast Marching Method based segmentation (as input
%                         to IMSEGFMM), this parameter can be useful in
%                         improving the accuracy of the segmentation
%                         output. Default value of this parameter is Inf,
%                         which means that there is no hard cutoff.
%
%
%   Class Support 
%   ------------- 
%   The input image I or volume V must be of one of the following classes: uint8, int8,
%   uint16, int16, uint32, int32, single, or double. It must be nonsparse.
%   MASK must be a logical array. C, R and P must be numeric vectors. Output
%   array W is an array of the same size as image I or volume V  and class double, 
%   unless I or V is of class single in which case W is also of class single.
%
%   Notes
%   -----
%   1. Double-precision floating point operations are used for internal
%      computations for all classes of I, except when I is of class single
%      in which case single-precision floating point operations are used
%      internally.
% 
%   2. If weight matrix W, computed using function GRAYDIFFWEIGHT, is used
%      as input to IMSEGFMM (for image segmentation), it is recommended
%      that the same values of C and R, or MASK are used for IMSEGFMM that
%      were used for the call to GRAYDIFFWEIGHT.
%      
%   Example 1
%   ---------
%   This example segments an object in the image using Fast Marching Method
%   based on the weights derived from grayscale intensity differences from
%   the intensity value at the seed location(s).
%
%     I = imread('cameraman.tif');
%     imshow(I)
%     title('Original Image')
% 
%     % Specify mask with seed locations. You can also use ROIPOLY to
%     % create a mask interactively.
%     mask = false(size(I));  
%     mask(170,70) = true;
% 
%     % Compute weights based on grayscale intensity differences
%     W = graydiffweight(I, mask, 'GrayDifferenceCutoff', 25);
% 
%     % Segment the image using the weights
%     thresh = 0.01;
%     [BW, D] = imsegfmm(W, mask, thresh);
%     figure, imshow(BW)
%     title('Segmented Image')
%     
%     % Geodesic distance matrix D can be thresholded using different 
%     % thresholds to get different segmentation results. 
%     figure, imshow(D)
%     title('Geodesic Distances')
%
%   See also GRADIENTWEIGHT, GRAYDIST, IMSEGFMM.

%   Copyright 2014-2017 The MathWorks, Inc.

narginchk(2,8);

[I, refGrayVal, rolloffFactor, grayDiffCutoff] = parse_inputs(varargin{:});

if isinteger(I)
    I = double(I);
end
if isempty(I)    
    W = I;
    return;
end

W = abs(I - refGrayVal);

if ~isinf(grayDiffCutoff)
    isSuppressed = W > grayDiffCutoff;
end
W = images.internal.imlinscale(W,[1e-3 1]);
if ~isinf(grayDiffCutoff)
    W(isSuppressed) = 1; % Set it to highest value in the linear scaled range
end

W = 1./(W.^(1./rolloffFactor)); % 1 is the lowest value in W at the output.
  
end

function [I, refGrayVal, rolloffFactor, grayDiffCutoff] = parse_inputs(varargin)

validImageTypes = {'uint8','int8','uint16','int16','uint32','int32', ...
    'single','double'};

I = varargin{1};
validateattributes(I,validImageTypes,{'nonsparse','real','3d'},mfilename,'I',1);

if isempty(varargin{2})
    error(message('images:validate:emptyParameter','refGrayVal'));
end

isArg2Numeric = isnumeric(varargin{2});
isArg2Logical = islogical(varargin{2});

if isArg2Logical
    typeOfSyntax = 'MaskSyntax';

elseif isArg2Numeric
    
    if ((nargin > 3) && isnumeric(varargin{3}) && isnumeric(varargin{4}))
        typeOfSyntax = 'CRPSyntax';
    
    elseif ((nargin > 2) && isnumeric(varargin{3}))
        
        typeOfSyntax = 'CRSyntax';

    else
        typeOfSyntax = 'RefGrayValSyntax';
    end
    
else
    error(message('images:validate:invalidNumericLogicalParam', ...
        'second',mfilename,'second'));
end

parser = inputParser;
parser.addRequired('I');

switch typeOfSyntax
    case 'RefGrayValSyntax'
        
        parser.addRequired('refGrayVal', @validateRefGrayVal);
        parser = addNVPairs(parser);

        parser.parse(varargin{:});
        res = parser.Results;
        
        refGrayVal = double(res.refGrayVal);
        
    case 'MaskSyntax'
        parser.addRequired('mask');
        parser = addNVPairs(parser);
        
        parser.parse(varargin{:});
        res = parser.Results;
        mask = res.mask;
        
        if isequal(size(mask),size(I))
            if all(mask(:) == false)
                error(message('images:validate:noTrueElement','MASK'));
            else
                refGrayVal = mean(I(mask));
            end
        else
            error(message('images:validate:unequalSizeMatrices','I','MASK'));
        end

        
    case 'CRSyntax'
        parser.addRequired('C', @validateSeed);
        parser.addRequired('R', @validateSeed);
        parser = addNVPairs(parser);
        
        parser.parse(varargin{:});
        res = parser.Results;

        C = res.C;
        R = res.R;

        if ~isequal(numel(R),numel(C))
            error(message('images:validate:unequalNumberOfElements','C','R'));
        end
         
        [nrows, ncols] = size(I);       
        isRinValidRange = all((R >= 1) & (R <= nrows));
        isCinValidRange = all((C >= 1) & (C <= ncols));   
        
        if ~isRinValidRange
            error(message('images:validate:SubscriptsOutsideRange','R'));
        end
        if ~isCinValidRange
            error(message('images:validate:SubscriptsOutsideRange','C'));
        end
        
        refGrayVal = mean(I(sub2ind([nrows ncols],R,C)));        
        
    case 'CRPSyntax'
        
        parser.addRequired('C', @validateSeed);
        parser.addRequired('R', @validateSeed);
        parser.addRequired('P', @validateSeed);
        parser = addNVPairs(parser);
        
        parser.parse(varargin{:});
        res = parser.Results;
        
        C = res.C;
        R = res.R;
        P = res.P;
        
        
        if ~isequal(numel(R),numel(C)) || ~isequal(numel(R),numel(P))
            error(message('images:validate:unequalNumberOfElements','C','R'));
        end
        
        [nrows, ncols, nplanes] = size(I);       
        isRinValidRange = all((R >= 1) & (R <= nrows));
        isCinValidRange = all((C >= 1) & (C <= ncols));   
        isPinValidRange = all((P >= 1) & (P <= nplanes));
        
        if ~isRinValidRange
            error(message('images:validate:SubscriptsOutsideRange','R'));
        end
        if ~isCinValidRange
            error(message('images:validate:SubscriptsOutsideRange','C'));
        end
        if ~isPinValidRange
            error(message('images:validate:SubscriptsOutsideRange','P'));
        end
        
        refGrayVal = mean(I(sub2ind([nrows ncols nplanes],R,C,P)));        

        
    otherwise
        assert(false,message('images:validate:invalidSyntax'));
        
end

% Default values for name-value pairs
rolloffFactor = double(res.RolloffFactor);
grayDiffCutoff = double(res.GrayDifferenceCutoff);

end

function parser = addNVPairs(parser)

    parser.addParameter('RolloffFactor',0.5, @validateRollOffFactor);
    parser.addParameter('GrayDifferenceCutoff',Inf, @validateGrayDiffCutoff);

end


function tf = validateRollOffFactor(rolloffFactor)

    validateattributes(rolloffFactor,{'numeric'},{'positive', ...
                    'finite', 'real', 'nonempty','scalar'}, mfilename, ...
                    'RolloffFactor');
    tf = true;
end


function tf = validateGrayDiffCutoff(grayDiffCutoff)

    validateattributes(grayDiffCutoff,{'numeric'},{'nonnegative', ...
                    'nonnan','real','nonempty','scalar'}, mfilename, ...
                    'GrayDifferenceCutoff');
    tf = true;
end


function  tf = validateRefGrayVal(refGrayVal)

    validRefGrayVal = {'uint8','int8','uint16','int16','uint32','int32', ...
    'single','double'};
    validateattributes(refGrayVal,validRefGrayVal, ...
             {'nonsparse','real','scalar','nonnan'},mfilename,'refGrayVal');
         
    tf = true;
end


function tf  = validateSeed(seed)

    validateattributes(seed,{'numeric'},{'nonsparse','integer','vector'}, ...
            mfilename);
    tf = true;
end