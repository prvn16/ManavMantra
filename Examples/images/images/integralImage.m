function intImage = integralImage(I, varargin)
%integralImage Compute upright or rotated integral image.
%   J = integralImage(I) computes the upright integral image of an
%   intensity image I.
%
%   J = integralImage(I, orientation) computes the integral image with
%   specified orientation. Orientation can be either 'upright' (default) or
%   'rotated'.
%
%   Notes
%   -----
%   1. If orientation is 'rotated', integralImage returns the integral
%      image for computing sums over rectangles rotated by 45 degrees. The
%      upright integral image is zero padded on top and left, resulting in
%      size(J) = size(I) + 1. The rotated integral image is padded at the 
%      top, left and right, resulting in size(J) = size(I) + [1 2]. This
%      facilitates easy computation of pixel sums along all image
%      boundaries.
%   2. If ndims(I)>2, such as for an RGB image, the integral image is
%      computed for all 2-D planes along the higher dimensions.
%
%   Class Support
%   -------------
%   Intensity image I can be any numeric class. The class of output 
%   integral image, J, is double.
%
%   Example 1
%   ---------
%   % Compute the integral image and use it to compute sum of pixels
%   % over an upright rectangular region in I.
%   I = magic(5)
%   
%   % define rectangular region as 
%   % [startingRow, startingColumn, endingRow, endingColumn]
%   [sR, sC, eR, eC] = deal(1, 3, 2, 4);
%    
%   % compute the sum over the region using the integral image
%   J = integralImage(I);
%   regionSum = J(eR+1,eC+1) - J(eR+1,sC) - J(sR,eC+1) + J(sR,sC)
%
%   Example 2
%   ---------
%   % Compute the integral image and use it to compute sum of pixels
%   % over a 45 degree rotated rectangular region in I
%   I = magic(5)
%
%   % define rotated rectangular region as [x, y, width, height]
%   % where x, y denote the indices of the top corner of the rectangle.
%   % width and height are along 45 degree lines from the top corner.
%   [x, y, w, h] = deal(3, 1, 3, 2);
%
%   % compute the sum over the region using the integral image
%   J = integralImage(I, 'rotated');
%   regionSum = J(y+w+h,x+w-h+1) + J(y,x+1) - J(y+h,x-h+1) - J(y+w,x+w+1);
%
%
%   See also integralFilter, integralBoxFilter, integralImage3.

%   Copyright 2010-2015 The MathWorks, Inc.

%   References:
%    - P.A. Viola and M.J. Jones. Rapid object detection using boosted
%      cascade of simple features. In CVPR (1), pages 511-518, 2001.
%
%    - Rainer Lienhart and Jochen Maydt. An Extended Set of Haar-like
%      Features for Rapid Object Detection. In International Conference
%      on Image Processing, pages I-900-913, 2002

%#codegen
%#ok<*EMCLS>
%#ok<*EMCA>

validateattributes(I, {'numeric','logical'}, {'nonsparse', 'real'}, ...
    mfilename, 'I');

narginchk(1,2);

nVarargs = length(varargin);
if(nVarargs == 0)
    orientStr = 'upright';   % default orientation
else
    orientStr = varargin{1};
end

% partial matching for integral image orientation
orientation = validatestring(orientStr, {'rotated', 'upright'}, ...
    mfilename, 'orientation', 2);

isUpright = strcmp(orientation, 'upright');
isSimulation = isempty(coder.target());

if isUpright && isSimulation
    intImage = integralimagemex(I);
    return;
end

% cast to double to maintain precision
if(~isa(I,'double'))
    iLoc = double(I);
else
    iLoc = I;
end

if ~isempty(I)
    if isUpright
        % only used in code generation
        outputSize = size(iLoc);
        outputSize(1) = outputSize(1) + 1;
        outputSize(2) = outputSize(2) + 1;
        
        intImage = zeros(outputSize);
        
        if ismatrix(iLoc)
            intImage(2:end, 2:end,:) = cumsum(cumsum(iLoc,1),2);
        else
            intImage(2:end, 2:end, :) = cumsum(cumsum(iLoc(:,:,:),1),2);
        end
        
    else % rotated integral image
        
        outputSize = size(iLoc);
        outputSize(1) = outputSize(1) + 1;
        outputSize(2) = outputSize(2) + 2;
        
        intImage = zeros(outputSize);
        
        if ismatrix(iLoc)
            intImage = computeRSAT(iLoc, outputSize);
        else
            % loop over each plane
            planes = prod(outputSize)/(outputSize(1)*outputSize(2));
            for p = 1 : planes
                intImage(:, :, p) = computeRSAT(iLoc(:,:,p), outputSize(1:2));
            end
        end
    end
else
    intImage = [];
end

end

function RSAT = computeRSAT(iLoc, outputSize)

height = outputSize(1);
width = outputSize(2)-1;

% deliberately initialize the RSAT to be bigger for easy computation
% along the boundaries
RSAT = zeros(outputSize);

% first row of the image is unchanged
RSAT(2,2:end-1) = iLoc(1,1:end);

% Compute the individual terms in the RSAT equation.
for y = 3:height
    RSAT(y,1) = RSAT(y-1,2);
    for x = 2:width
        % The RSAT entry corresponding to the north-west neighbor of
        % the current RSAT entry
        RSATNorthWest = RSAT(y-1,x-1);
        
        % The RSAT entry corresponding to the north-east neighbor of
        % the current RSAT entry
        RSATNorthEast = RSAT(y-1,x+1);
        
        % The RSAT entry corresponding to the north neighbor of the
        % north neighbor of the current RSAT entry
        RSATNorthOfNorth = RSAT(y-2,x);
        
        % The current image pixel
        currImgPixel = iLoc(y-1,x-1);
        
        % The north neighbor of the current image pixel
        northNeighbor = iLoc(y-2,x-1);
        
        % Compute the current RSAT entry.
        RSAT(y,x) = RSATNorthWest + RSATNorthEast - ...
            RSATNorthOfNorth + currImgPixel + northNeighbor;
    end
    RSAT(y,end) = RSAT(y-1,end-1);
end

end
