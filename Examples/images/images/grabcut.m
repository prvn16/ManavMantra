function BW = grabcut(A,L,roi,varargin)
%GRABCUT Segment image into foreground and background using iterative graph-based segmentation.
%
%   BW = GRABCUT(A,L,ROI) segments the image A into
%   foreground and background regions using GrabCut with the label
%   matrix L specifying the subregions of the image. ROI is a logical mask
%   designating the initial region of interest.
%
%   BW = GRABCUT(A,L,ROI,FOREMASK,BACKMASK) segments the image A into
%   foreground and background regions using GrabCut with the label
%   matrix L specifying the subregions of the image. FOREMASK and BACKMASK
%   are masks designating pixels in the image as foreground and background,
%   respectively.
%
%   BW = GRABCUT(A,L,ROI,FOREIND,BACKIND) segments the image A into
%   foreground and background regions using GrabCut with the label
%   matrix L specifying the subregions of the image. FOREIND and BACKIND
%   specify the linear indices of the pixels in the image marked as
%   foreground and background, respectively.
%
%   BW = GRABCUT(V,_____) segments the volume V into foreground and
%   background regions.
%
%   BW = GRABCUT(_____,NAME,VALUE) segments the image using name-value
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
%       'MaximumIterations'     - Positive scalar integer value that
%                                 determines the maximum number of 
%                                 iterations performed by the algorithm.
%                                 The algorithm could converge to a
%                                 solution before reaching the maximum
%                                 number of iterations. The default value
%                                 is 5.
%
%   Class Support
%   -------------
%   The input image A is an array of one of the following classes: uint8,
%   uint16, int16 (grayscale only), single, or double. It must be real,
%   finite, and nonsparse. L must be a valid label matrix for image A. ROI
%   must be a logical array where all pixels that define the region of
%   interest are equal to true. FOREMASK and BACKMASK must be logical
%   arrays. FOREIND and BACKIND must be vectors of linear indices
%   identifying pixels in the label matrix L. Output image BW is the same
%   size as the label matrix L.
%
%   Notes
%   -----
%
%   1. The algorithm treats all subregions fully or partially outside the
%   ROI mask as belonging to the background. An optimal segmentation will
%   be obtained when the object that is desired is fully contained within
%   the ROI with a small amount of background pixels surrounding the
%   object.
%
%   2. For double and single images, the range of the image is assumed to
%   be [0 1]. For uint16, int16, and uint8 images, the range is assumed to
%   be the full range for the given data type.
%
%   3. For grayscale images, the size of L, FOREMASK, and BACKMASK must
%   match the size of the image A. For color and multi-channel images, L,
%   FOREMASK, and BACKMASK must be a 2D array with the first two dimensions
%   identical to the first two dimensions of the image A.
%
%   4. A given subregion of the label matrix should not be marked as
%   belonging to both the foreground mask and the background mask. If a
%   region of the label matrix contains pixels belonging to both the
%   foreground mask and background mask, the algorithm effectively treats
%   the region as unmarked.
%
%   5. All subregions outside the region of interest defined by ROI are
%   assumed to belong to the background. Marking one of these subregions as
%   belonging to foreground or background mask will have no effect on the
%   resulting segmentation.
%
%
%   Example 1
%   ---------
%
%   % Read in image.
%   RGB = imread('peppers.png');
% 
%   % Generate label matrix
%   L = superpixels(RGB,500);
% 
%   % Select region of interest
%   figure; 
%   imshow(RGB)
%   h1 = impoly(gca,[72,105; 1,231; 0,366; 104,359;...
%       394,307; 518,343; 510,39; 149,72]);
%   roiPoints = getPosition(h1);
%   roi = poly2mask(roiPoints(:,1),roiPoints(:,2),size(L,1),size(L,2));
% 
%   % Perform GrabCut
%   BW = grabcut(RGB,L,roi);
% 
%   % Create masked image.
%   maskedImage = RGB;
%   maskedImage(repmat(~BW,[1 1 3])) = 0;
%   figure;
%   imshow(maskedImage)
%
%   Example 2
%   ---------
%
%   % Load 3D image
%   load mristack
%   V = mristack;
%
%   % Create 2D mask for initial foreground and background seed points
%   seedLevel = 10;
%   fseed = V(:,:,seedLevel) > 75;
%   bseed = V(:,:,seedLevel) == 0;
%
%   figure;
%   imshow(fseed)
%
%   figure;
%   imshow(bseed)
%
%   % Place seed points into empty 3D mask
%   fmask = zeros(size(V));
%   bmask = fmask;
%   fmask(:,:,seedLevel) = fseed;
%   bmask(:,:,seedLevel) = bseed;
%
%   % Create initial region of interest
%   roi = false(size(V));
%   roi(10:end-10,10:end-10,:) = true;
%
%   % Generate label matrix
%   L = superpixels3(V,500);
%
%   % Perform GrabCut
%   bw = grabcut(V,L,roi,fmask,bmask);
%
%   % Display 3D segmented image
%   volumeViewer(bw);
%
%
%   See also SUPERPIXELS, LAZYSNAPPING, WATERSHED, LABELMATRIX, imageSegmenter.
%
%   Copyright 2017 The MathWorks, Inc.
%
%   References
%   ----------
%
%   [1] C. Rother, V. Kolmogorov, A. Blake, "GrabCut - Interactive
%   Foreground Extraction using Iterated Graph Cuts" ACM Transactions on 
%   Graphics (SIGGRAPH), vol. 23, pp. 309–314, 2004

[roi,is3D] = validateInputs(A,L,roi);

options = parseOptionalInputs(size(L),is3D,varargin{:});

numRegions = max(L(:));

grabObj = images.graphcut.internal.grabcut(A,L,numRegions,options.Connectivity,options.MaximumIterations);

if numRegions > 1
    % Iterative process
    grabObj = grabObj.addBoundingBox(roi);
    
    % Touch-up marks
    if ~isempty(options.foreground) || ~isempty(options.background)
        grabObj = grabObj.addHardConstraints(options.foreground,options.background);
        grabObj = grabObj.segment();
    end
end

BW = grabObj.Mask;

end

function options = parseOptionalInputs(sz,is3D,varargin)

% Define structure holding default values for optional arguements and
% Name/Value pairs
if is3D
    defaultConn = 26;
else
    defaultConn = 8;
end

parser = inputParser();
parser.addOptional('foreground',[],@validateForeground);
parser.addOptional('background',[],@validateBackground);
parser.addParameter('Connectivity',defaultConn,@validateConnectivity);
parser.addParameter('MaximumIterations',5,@validateMaximumIterations);
parser.parse(varargin{1:end});
options = parser.Results;

options.MaximumIterations = double(options.MaximumIterations);

% Validate Connectivity
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

% Validate Foreground and Background marks
if ~isempty(options.foreground)
    options.foreground = getIndices(options.foreground, sz);
end

if ~isempty(options.background)
    options.background = getIndices(options.background, sz);
end

end

function [roi,is3D] = validateInputs(A,L,roi)

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

if ~is3D
    if (size(A,3) ~= 3) && (size(A,3) ~= 1)
        error(message('images:lazysnapping:mustBeRGBorGrayscale','A'));
    end
end

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

% Validate ROI
validMaskTypes = {'logical'};
validateattributes(roi,validMaskTypes,{'nonnan','nonsparse', ...
    'real','nonempty','nonnegative'},mfilename,'roi',3);

if islogical(roi)
    % Mask ROI, valid for 2D and 3D cases
    if ~isequal(size(roi),size(L))
        error(message('images:lazysnapping:invalidROIMaskDimensions'));
    end
end

end

function TF = validateMaximumIterations(iters)

validateattributes(iters,{'numeric'},{'nonempty','integer','real','scalar','positive','finite','nonsparse'},...
    mfilename,'MaximumIterations');

TF = true;

end

function TF = validateForeground(foreground)

validateattributes(foreground,{'numeric','logical'},{'integer','real','nonnegative','nonnan','nonsparse'},...
    mfilename,'foreground');

TF = true;

end

function TF = validateBackground(background)

validateattributes(background,{'numeric','logical'},{'integer','real','nonnegative','nonnan','nonsparse'},...
    mfilename,'background');

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