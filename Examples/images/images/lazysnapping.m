function BW = lazysnapping(A,L,foreground,background,varargin)
%LAZYSNAPPING Segment image into foreground and background using graph-based segmentation.
%
%   BW = LAZYSNAPPING(A,L,FOREMASK,BACKMASK) segments the image A into
%   foreground and background regions using lazy snapping with the label
%   matrix L specifying the subregions of the image. FOREMASK and BACKMASK
%   are masks designating pixels in the image as foreground and background,
%   respectively.
%
%   BW = LAZYSNAPPING(A,L,FOREIND,BACKIND) segments the image A into
%   foreground and background regions using lazy snapping with the label
%   matrix L specifying the subregions of the image. FOREIND and BACKIND
%   specify the linear indices of the pixels in the image marked as
%   foreground and background, respectively.
%
%   BW = LAZYSNAPPING(V,_____) segments the volume V into foreground and
%   background regions.
%
%   BW = LAZYSNAPPING(_____,NAME,VALUE) segments the image using name-value
%   pairs to control aspects of the segmentation.
%
%   Parameters include:
%
%       'Connectivity'          - Scalar value representing the 
%                                 connectivity of connected components. For
%                                 2D images, value must be either 4 or 
%                                 8 (default). For 3D images, value must be
%                                 6, 18, or 26 (default).
%
%       'EdgeWeightScaleFactor' - Positive scalar value representing the
%                                 scale factor for the edge weights between
%                                 subregions of the label matrix. The
%                                 default value is 500, and typical values
%                                 are [10 1000]. Increasing this parameter
%                                 increases the likelihood that neighboring
%                                 subregions will be labelled together as
%                                 either foreground for background.
%
%   Class Support
%   -------------
%   The input image A is an array of one of the following classes: uint8,
%   uint16, int16 (grayscale only), single, or double. It must be real,
%   finite, and nonsparse. L must be a valid label matrix for image A.
%   FOREMASK and BACKMASK must be logical arrays. FOREIND and BACKIND must
%   be vectors of linear indices identifying pixels in the label matrix L.
%   Output image BW is the same size as the label matrix L.
%
%   Notes
%   -----
%
%   1. For double and single images, the range of the image is assumed to
%   be [0 1]. For uint16, int16, and uint8 images, the range is assumed to
%   be the full range for the given data type. If the values in the image
%   do not match the expected range based on the data type, it may be
%   necessary to scale the image to the expected range or adjust the
%   'EdgeWeightScaleFactor' to improve segmentation results.
%
%   2. For 2D and 3D grayscale images, the size of L, FOREMASK, and
%   BACKMASK must match the size of the image A. For color and
%   multi-channel images, L, FOREMASK, and BACKMASK must be a 2D array with
%   the first two dimensions identical to the first two dimensions of the
%   image A.
% 
%   3. A given subregion of the label matrix should not be marked as
%   belonging to both the foreground mask and the background mask. If a
%   region of the label matrix contains pixels belonging to both the
%   foreground mask and background mask, the algorithm effectively treats
%   the region as unmarked.
% 
%   4. The Lazy Snapping algorithm developed by Li et al. clustered
%   foreground and background values using the K-means method; however,
%   this implementation of the Lazy Snapping algorithm does not cluster
%   similar foreground or background pixels. To improve performance, reduce
%   the number of pixels with similar values that are identified as
%   foreground or background.
%
%
%   Example 1
%   ---------
%
%   % Read in image.
%   RGB = imread('peppers.png');
% 
%   % Mark locations on image as foreground
%   figure; 
%   imshow(RGB)
%   h1 = impoly(gca,[34,298;114,140;195,135;...
%       259,200;392,205;467,283;483,104],'Closed',false);
%   foresub = getPosition(h1);
%   foregroundInd = sub2ind(size(RGB),foresub(:,2),foresub(:,1));
% 
%   % Mark locations on image as background
%   figure; 
%   imshow(RGB)
%   h2 = impoly(gca,[130,52;170,32],'Closed',false);
%   backsub = getPosition(h2);
%   backgroundInd = sub2ind(size(RGB),backsub(:,2),backsub(:,1));
% 
%   % Generate label matrix
%   L = superpixels(RGB,500);
% 
%   % Perform Lazy Snapping
%   BW = lazysnapping(RGB,L,foregroundInd,backgroundInd);
% 
%   % Create masked image.
%   maskedImage = RGB;
%   maskedImage(repmat(~BW,[1 1 3])) = 0;
%   figure; 
%   imshow(maskedImage)
%
%
%   Example 2
%   ---------
%
%   % Load 3D image
%   D = load('mri');
%   V  = squeeze(D.D);
% 
%   % Create 2D mask for intial foreground and background seed points
%   seedLevel = 10;
%   fseed = V(:,:,seedLevel) > 75;
%   bseed = V(:,:,seedLevel) == 0;
%   figure; 
%   imshow(fseed)
%   figure; 
%   imshow(bseed)
% 
%   % Place seed points into empty 3D mask
%   fmask = zeros(size(V));
%   bmask = fmask;
%   fmask(:,:,seedLevel) = fseed;
%   bmask(:,:,seedLevel) = bseed;
% 
%   % Generate label matrix
%   L = superpixels3(V,500);
%
%   % Perform Lazy Snapping
%   bw = lazysnapping(V,L,fmask,bmask);
% 
%   % Display 3D segmented image
%   figure;
%   p = patch(isosurface(double(bw)));
%   p.FaceColor = 'red';
%   p.EdgeColor = 'none';
%   daspect([1 1 27/128]);
%   camlight; lighting phong
%
%
%   See also SUPERPIXELS, SUPERPIXELS3, WATERSHED, LABELMATRIX, imageSegmenter.
%
%   Copyright 2016 The MathWorks, Inc.
%
%   References
%   ----------
%
%   [1] Y. Li, S. Jian, C. Tang, H. Shum, "Lazy Snapping," In proceedings
%   from the 31st International Conference on Computer Graphics and
%   Interactive Techniques, 2004.

[foregroundInd,backgroundInd,is3D] = validateInputs(A,L,foreground,background);

options = parseOptionalInputs(is3D,varargin{:});

numRegions = max(L(:));

snapObj = images.graphcut.internal.lazysnapping(A,L,numRegions,options.Connectivity,options.EdgeWeightScaleFactor);

if numRegions > 1
    snapObj = snapObj.addHardConstraints(foregroundInd,backgroundInd);
    snapObj = snapObj.segment();
end

BW = snapObj.Mask;

end

function options = parseOptionalInputs(is3D,varargin)

% Define structure holding default values for optional arguements and
% Name/Value pairs
if is3D
    defaultConn = 26;
else
    defaultConn = 8;
end

parser = inputParser();
parser.addParameter('Connectivity',defaultConn,@validateConnectivity);
parser.addParameter('EdgeWeightScaleFactor',500,@validateEdgeWeight);
parser.parse(varargin{1:end});
options = parser.Results;

options.EdgeWeightScaleFactor = double(options.EdgeWeightScaleFactor);

if is3D
    if isequal(options.Connectivity,6) || isequal(options.Connectivity,18) || isequal(options.Connectivity,26)
        options.Connectivity = double(options.Connectivity);
    else
        error(message('images:lazysnapping:invalid3DConnectivity',num2str(options.Connectivity)));
    end
else
    if isequal(options.Connectivity,4) || isequal(options.Connectivity,8)
        options.Connectivity = double(options.Connectivity);
    else
        error(message('images:lazysnapping:invalid2DConnectivity',num2str(options.Connectivity)));
    end
end

end

function [foregroundInd,backgroundInd,is3D] = validateInputs(A,L,foreground,background)

% Validate A
validImageTypes = {'uint8','uint16','int16',...
                   'single','double'};
validateattributes(A,validImageTypes,{'finite','nonnan','nonsparse', ...
    'real','nonempty'},mfilename,'A',1);

if ~ismatrix(A) && ndims(A) ~= 3
    error(message('images:lazysnapping:mustBe2Dor3D','A'));
end

validColorImage = (ndims(A) == 3) && (size(A,3) == 3);

if isa(A,'int16') && validColorImage
    error(message('images:lazysnapping:expectGrayscaleInt16'));
end

% Validate labelMatrix
is3D = size(L,3) > 1;

validLabelMatrixTypes = {'numeric','logical'};
validateattributes(L,validLabelMatrixTypes,{'finite','nonnan', ...
    'nonsparse','real','nonnegative','integer','nonempty'},mfilename,'L',2);

if ~ismatrix(L) && ndims(L) ~= 3
    error(message('images:lazysnapping:mustBe2Dor3D','L'));
end

invalidImageDims = ~isequal(size(A,1),size(L,1)) || ...
    ~isequal(size(A,2),size(L,2)) ...
    || (is3D && ~isequal(size(A),size(L)));

if invalidImageDims
    error(message('images:lazysnapping:differentMatrixSize','A','L'))
end

% Validate foreground
validMaskTypes = {'logical','numeric'};
validateattributes(foreground,validMaskTypes,{'nonnan','nonsparse', ...
    'real','nonempty','nonnegative','integer'},mfilename,'foreground',3);

% Validate background
validMaskTypes = {'logical','numeric'};
validateattributes(background,validMaskTypes,{'nonnan','nonsparse', ...
    'real','nonempty','nonnegative','integer'},mfilename,'background',4);

foregroundInd = getIndices(foreground, size(L));
backgroundInd = getIndices(background, size(L));

if isempty(foregroundInd) || isempty(backgroundInd)
    error(message('images:lazysnapping:emptyMask'))
end

end

function TF = validateEdgeWeight(lambda)

validateattributes(lambda,{'numeric'},{'nonempty','real','scalar','nonnegative','finite','nonsparse'},...
    mfilename,'EdgeWeightScaleFactor');

TF = true;

end

function TF = validateConnectivity(conn)

validateattributes(conn,{'numeric'},{'nonempty','real','scalar','positive','finite','nonsparse'},...
    mfilename,'Connectivity');

TF = true;

end

function ind = getIndices(scribbles, sz)

if isequal(size(scribbles),sz)
    % scribbles passed in as mask
    if ~islogical(scribbles)
        scribbles = logical(scribbles);
    end
    ind = find(scribbles);
elseif isvector(scribbles)
    % scribbles passed in as linear indices
    ind = scribbles(:);
    if max(ind) > prod(sz)
        error(message('images:lazysnapping:invalidLinearIndices'))
    end  
else
    error(message('images:lazysnapping:invalidMaskDimensions'))
end

end