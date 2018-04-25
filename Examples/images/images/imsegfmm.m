function [BW, D] = imsegfmm(varargin)
%IMSEGFMM Binary image segmentation using Fast Marching Method.
%
%   BW = imsegfmm(W, MASK, THRESH) returns a segmented image BW, which is
%   computed based on the output of the Fast Marching Method with the
%   weights for each pixel defined in the input array W, and the seed
%   locations specified by MASK. Ideally, W should have high values in the
%   region which is to be segmented as the foreground (object) and low
%   values elsewhere. The weight array W can be computed using function
%   GRAYDIFFWEIGHT or GRADIENTWEIGHT. W must have non-negative values. MASK
%   is a logical image of the same size as W. Locations where MASK is true
%   are seed locations. BW is a logical array of the same size as W. THRESH
%   is a non-negative scalar in the range [0 1] which specifies level at
%   which is output of the Fast Marching Method is thresholded to obtain
%   the output binary image BW. Low values of THRESH typically result in
%   large foreground region(s) (logical true) in BW, and high values of
%   THRESH produce small foreground region(s).
%
%   BW = imsegfmm(W, C, R, THRESH) computes the segmented images with seed
%   locations specified by C and R. C and R are vectors containing the
%   column and row indices of the seed locations. C and R must contain
%   values which are valid pixel indices in W.
%
%   BW = imsegfmm(W, C, R, P, THRESH) computes the segmented images with
%   seed locations specified by C, R and P. C, R and P are vectors
%   containing the column, row and plane indices of the seed locations. C, R
%   and P must contain values which are valid pixel indices in W.
%
%   [BW, D] = imsegfmm(...) also returns the normalized geodesic distance
%   map D computed using the Fast Marching Method. BW is a thresholded
%   version of D, where all the pixels that have normalized geodesic
%   distance values less than THRESH are considered foreground pixels and
%   set to true. D can be thresholded at different levels to obtain
%   different segmentation results. 
%
%   Class Support 
%   ------------- 
%   The input array W must be of one of the following classes: uint8, int8,
%   uint16, int16, uint32, int32, single, or double. They must be
%   nonsparse. MASK must be a logical array. C, R and P must be numeric
%   vectors. THRESH must be a numeric scalar. Output array BW is a logical
%   array of the same size as W. Output array D is an array of the same
%   size as W and class double, unless W is of class single in which case D
%   is also of class single.
%
%   Notes
%   -----
%   1. Double-precision floating point operations are used for internal
%      computations for all classes of W, except when W is of class single
%      in which case single-precision floating point operations are used
%      internally.
% 
%   2. If weight matrix W is computed using function GRAYDIFFWEIGHT, it is
%      typical that the same values of C and R, or MASK are used for
%      IMSEGFMM that were used for the call to GRAYDIFFWEIGHT.
% 
%   3. Pixels with zero weight value will have the geodesic distance value
%      of Inf in the corresponding location in D, and will be part of the
%      background (logical false) in the segmented image BW. Same is also
%      true of pixels whose weight is set to NaN in W. 
%      
%   Example 1
%   ---------
%   This example segments an object in the image using Fast Marching Method
%   based on differences in grayscale intensity as compared to the seed
%   location(s).
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
%
%   Example 2
%   ---------
%   This example segments an object in the Volume using Fast Marching Method
%   based on differences in grayscale intensity as compared to the seed
%   location(s).
%
%     % Load the volume
%     load mri
%     V = squeeze(D);
%  
%     % Set the sed locations
%     seedR = 75; seedC = 60; seedP = 10;
% 
%     % Compute weights based on grayscale intensity differences
%     W = graydiffweight(V,  seedC, seedR,seedP , 'GrayDifferenceCutoff', 25);
% 
%     % Segment the image using the weights
%     thresh = 0.002;
% 
%     % Segment the weight image using imsegfmm
%     BW = imsegfmm(W,  seedC, seedR,seedP, thresh);
% 
%     % Visualize the segmented image using iso surface
% 
%     figure;
%     p = patch(isosurface(double(BW)));
%     p.FaceColor = 'red';
%     p.EdgeColor = 'none';
%     daspect([1 1 27/64]);
%     camlight; lighting phong;
%
%
%   References:
%   -----------
%   [1] J. A. Sethian, Level Set Methods and Fast Marching Methods: 
%       Evolving Interfaces in Computational Geometry, Fluid Mechanics, 
%       Computer Vision, and Materials Science, Cambridge University Press,
%       1999. 
%
%   See also ACTIVECONTOUR, GRADIENTWEIGHT, GRAYDIFFWEIGHT, GRAYDIST, imageSegmenter.

%   Copyright 2014-2016 The MathWorks, Inc.

narginchk(3,5);

[W, sourcePntIdx, thresh] = parse_inputs(varargin{:});

if isinteger(W)
    W = double(W);
end
if isempty(W)    
    BW = false(size(W));
    D = W;
    return;
end

sourcePntIdx = sourcePntIdx - 1; % For 0 based indexing. 

D = images.internal.fastmarchingmex(W, sourcePntIdx);

% Normalize distance to range [0 1].
maxD = max(D(:));
if (maxD > 0) % minD is always 0.
    if isinf(maxD) 
        % If Inf is present only normalize the non-Inf elements.
        infIdx = ~isinf(D);
        maxD = max(D(infIdx));
        if isempty(maxD)
            maxD = 1;
        end
        D(infIdx) = D(infIdx)/maxD;
    else
        D = D/maxD;  
    end
end
BW = (D <= thresh);

end

function [W, sourcePntIdx, thresh] = parse_inputs(varargin)

% W = [];
% sourcePntIdx = [];
% thresh = [];

parser = inputParser;

parser.addRequired('W', @validateWeight);

switch(nargin)
    
    case 3 % BW = imsegfmm(W, MASK, THRESH)
        
        parser.addRequired('mask', @validateMask);
        parser.addRequired('thresh', @validateThreshold);
        
        parser.parse(varargin{:});
        res = parser.Results;
        
        W = res.W;
        mask = res.mask;
        thresh = double(res.thresh);
        
        if isequal(size(mask),size(W))
            sourcePntIdx = find(mask);        
        else
            error(message('images:validate:unequalSizeMatrices','W','MASK'));
        end
        
        
    case 4 % BW = imsegfmm(W, C, R, THRESH)
        
        parser.addRequired('C', @validateSeed);
        parser.addRequired('R', @validateSeed);
        parser.addRequired('thresh', @validateThreshold);
        
        parser.parse(varargin{:});
        res = parser.Results;
        
        W  =res.W;
        C = res.C;
        R = res.R;
        thresh = double(res.thresh);
        
        if ~isequal(numel(R),numel(C))
            error(message('images:validate:unequalNumberOfElements','C','R'));
        end
        
        if( ndims(W) > 2) %#ok<ISMAT>
           error(message('images:validate:tooManyDimensions', 'W', 2)) 
        end
        
        
        [nrows, ncols] = size(W);
        
        isRinValidRange = all((R >= 1) & (R <= nrows));
        isCinValidRange = all((C >= 1) & (C <= ncols)); 

        
        if ~isRinValidRange
            error(message('images:validate:SubscriptsOutsideRange','R'));
        end
        if ~isCinValidRange
            error(message('images:validate:SubscriptsOutsideRange','C'));
        end
        
         sourcePntIdx = sub2ind([nrows ncols],R,C);
        
        
    case 5 % BW = imsegfmm(W, C, R, P, THRESH)
        
        parser.addRequired('C', @validateSeed);
        parser.addRequired('R', @validateSeed);
        parser.addRequired('P', @validateSeed);
        parser.addRequired('thresh', @validateThreshold);
        
        parser.parse(varargin{:});
        res = parser.Results;
        
        W = res.W;
        C = res.C;
        R = res.R;
        P = res.P;
        thresh = double(res.thresh);
        
        if ~isequal(numel(R),numel(C), numel(P))
            error(message('images:validate:unequalNumberOfElements3', 'C', 'R', 'P'));
        end
        
        if( ndims(W) < 3) %#ok<ISMAT>
           error(message('images:validate:tooFewDimensions', 'W', 3)) 
        end
        
        
        [nrows, ncols, nplanes] = size(W);
        
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
        
        sourcePntIdx = sub2ind([nrows ncols nplanes],R,C,P);
        
    otherwise
        error(message('images:validate:invalidSyntax'));
        
end


end

function tf = validateWeight(W)
    validImageTypes = {'uint8','int8','uint16','int16','uint32','int32', ...
    'single','double'};
    validateattributes(W,validImageTypes,{'nonsparse','real','3d', ...
        'nonempty','nonnegative'}, mfilename,'W',1);
    tf = true;
end
        

function tf = validateMask(mask)
    validateattributes(mask,{'logical'},{'nonsparse','real','3d', ...
        'nonempty'}, mfilename,'Mask',2);
    tf = true;
end


function tf = validateThreshold(thresh)
    validateattributes(thresh,{'numeric'},{'nonsparse','real','scalar', ...
        'nonnan','>=',0,'<=',1},mfilename,'THRESH');
    tf = true;
end

function tf = validateSeed(seedPoints)
    validateattributes(seedPoints,{'numeric'},{'nonsparse','integer'}, ...
        mfilename);
    tf = true;
end   