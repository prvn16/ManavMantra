function varargout = imregmtb(varargin)
%IMREGMTB  Register 2-D images using median threshold bitmaps.
%    [R1, R2, ..., SHIFT] = IMREGMTB(M1, M2, ..., F) registers an arbitrary
%    number of moving images M1, M2, ... with respect to the fixed
%    (reference) image F using the median threshold bitmap technique. R1,
%    R2, ... are the registered images. SHIFT is an M-by-2 vector (where M
%    is number of moving images) containing the estimated displacement between 
%    each moving image and fixed image.
%
%    Class Support
%    -------------
%    M1, M2, ..., and F must be uint8, uint16, double or single. They must 
%    be real, finite, non-sparse, RGB or grayscale images. All the images
%    must be of same class and size. R1, R2, ... output images have the same 
%    class as M1, M2, ...,F. SHIFT is always of class double.
%
%    Example
%    -------
%    % Load multiple images.
%    m1 = imread('office_1.jpg');
%    m2 = imread('office_2.jpg');
%    m3 = imread('office_3.jpg');
%    f1 = imread('office_4.jpg');
%       
%    % Manually shift the moving images
%    m1 = imtranslate(m1, [3 3]);
%    m2 = imtranslate(m2, [2 -1]);
%    m3 = imtranslate(m3, [-3 5]);
%    figure; montage({m1, m2, m3, f1});
%    title('Input image sequences');
%
%    % Register the spatially shifted images to the last image.
%    [r1, r2, r3, shift] = imregmtb(m1, m2, m3, f1);
%
%    figure; montage({r1, r2, r3, f1});
%    title('Registered images');
%
%    Reference
%    ---------
%    [1] E.Reinhard, W.Heidrich, P.Debevec, S.Pattanaik, G. Ward, K.Myszkowski,
%    "High dynamic range imaging: acquisition, display, and image-based lighting",
%    2010, Page No. 155-170
%
%    See also IMTRANSLATE, BLENDEXPOSURE, IMREGCORR, IMREGISTER.

%  Copyright 2017 The MathWorks, Inc.

narginchk(2,inf);
I = parseInputs(varargin{:});
originalClass = class(I{1});

% Convert the pixels values into double in the range [0,255]
if isfloat(I{1})
    % The algorithm assumes the input image is in single or double
    for i = 1:numel(I)
        I{i} = double(uint8(min(1, max(0, I{i}))*255));
    end
elseif isa(I{1},'uint16')
    % Convert to double if image is in uint16 type
    for i = 1:numel(I)
        I{i} = double(im2uint8(I{i}));
    end
else
    % Convert to double if image is in uint8 type
    for i = 1:numel(I)
        I{i} = double(I{i});
    end
end


numLevels = 6; % Number of pyramid levels
numImages = length(I);
shift = zeros(numImages,2);
for idx = numImages:-1:2
    % Construct pyramids for ref and source image. Here first image is
    % considered as a reference image
    [refPyr,srcPyr] = pyrConstruction(I{idx},I{idx-1},numLevels);
    
    % If all zeros or ones or same pixel intensities are coming then it will
    % lead to wrong shift estimation. Below condition keeps away propogration
    % of misleading shifts.
    refImg = refPyr{1};
    srcImg = srcPyr{1};
    
    isUniformRefImage = all(refImg(:) == refImg(1));
    isUniformSrcImage = all(srcImg(:) == srcImg(1));
    if (isUniformRefImage && isUniformSrcImage)        
        error(message('images:imregmtb:pixelsWithSameIntensities'));
    end
    
    % Shifts are computed based on xor operation and it is accumulated from
    % coarser level to fine level
    shift(idx-1,:) = computeOffset(refPyr,srcPyr,numLevels);
    % Accumulate shifts for other images
    shift(idx-1,:) = shift(idx-1,:) + shift(idx,:);
    
    % Shift the source image based on estimated shifts
    alignedImg = imtranslate(I{idx-1}, shift(idx-1,:));
    
    % Convert registered image back to input image class
    alignedImg = convertToOriginalClass(alignedImg, originalClass);
    varargout{idx-1} = alignedImg;
end

% Translation between moving images and fixed image
varargout{numImages} = shift(1:end-1,:);
end


function [refPyr,srcPyr] = pyrConstruction(ref,src,nlev)

% Grayscale image by adding more weights to green channel
if size(ref,3) == 1
    gRef = uint8(ref);
    gSrc = uint8(src);
else
    gRef = uint8((ref(:,:,1)*54 + ref(:,:,2)*183 + ref(:,:,3)*19)/256);
    gSrc = uint8((src(:,:,1)*54 + src(:,:,2)*183 + src(:,:,3)*19)/256);
end

% Pyramid construction
srcPyr = cell(nlev,1);
refPyr = cell(nlev,1);
srcPyr{1} = gSrc;
refPyr{1} = gRef;
for levels = 2:nlev
    pyrRef = impyramid(refPyr{levels-1},'reduce');
    pyrSrc = impyramid(srcPyr{levels-1},'reduce');
    refPyr{levels} = pyrRef;
    srcPyr{levels} = pyrSrc;
end
end


function estShift = computeOffset(refPyr,srcPyr,numLevels)
% Compute Median Threshold Bitmap (MTB) shifts between source and reference
% image

shift = [0 0]; % Initialization of translation
for thisLevel = numLevels:-1:1
    
    % Coarser to fine level pyramid
    refImg = refPyr{thisLevel};
    srcImg = srcPyr{thisLevel};
    
    % Find the median value
    refHistogram = median(refImg(:));
    srcHistogram = median(srcImg(:));
    
    % Convert into binary map
    refBinaryMap = refImg > refHistogram;
    srcBinaryMap = srcImg > srcHistogram;
    
    
    % Remove noise near to median pixel (+/- 4 pixels). 
    refNoiseMask = (refImg < refHistogram - 4) | (refImg > refHistogram + 4);
    srcNoiseMask = (srcImg < srcHistogram - 4) | (srcImg > srcHistogram + 4);
    
    minErr = size(refImg,1)*size(refImg,2); % Initialize the error
    for i = -1:1
        for j = -1:1
            xs = shift(1) + i;
            ys = shift(2) + j;
            estSrcShift = imtranslate(srcBinaryMap, [xs ys]);
            estSrcShiftAfterNoiseShift = imtranslate(srcNoiseMask, [xs ys]);
            diffPixels = xor(refBinaryMap, estSrcShift) & refNoiseMask & estSrcShiftAfterNoiseShift;
            err = sum(diffPixels(:));
            
            if err < minErr
                estShift = [xs ys];
                minErr = err;
            end
        end
    end
    
    % Easy way to estimate shifts for higher level of pyramid 
    shift = estShift*2;
end
end

function im = parseInputs(varargin)

parser = inputParser;
parser.FunctionName = mfilename;

chkImg = varargin{1};
validateattributes(chkImg,{'single', 'double', 'uint8','uint16'},...
    {'nonsparse','real'}, mfilename,'chkImg',1);

if ndims(chkImg)>= 4 || (size(chkImg,3) ~= 3 && size(chkImg,3) ~= 1)
    error(message('images:imregmtb:invalidImageFormat'));
end

if size(chkImg,1) < 64 || size(chkImg,2) < 64
    error(message('images:imregmtb:smallerSizeImage'));
end

im = {};
cnt = 0;
originalClass = class(chkImg);
for ind = 1:numel(varargin)
    if ~isnumeric(varargin{ind})
        break;
    end
    im{end+1} = varargin{ind}; %#ok<AGROW>
    if ~strcmp(originalClass,class(varargin{ind}))
        error(message('images:imregmtb:invalidInputClass'));
    end
    cnt = cnt + 1;
end

% If other than image is passed
if cnt ~= length(varargin)
    error(message('images:imregmtb:invalidImageFormat'));
end

imgSize = size(chkImg);
for i = 1:numel(im)
    validateattributes(im{i},...
        {'single', 'double', 'uint8','uint16'},...
        {'real', 'nonsparse','nonnan','finite', 'nonempty','size',imgSize}, ...
        mfilename, 'im', i)
end

end

function B = convertToOriginalClass(B, OriginalClass)

if strcmp(OriginalClass,'uint8')
    B = uint8(B);
elseif strcmp(OriginalClass,'uint16')
    B = im2uint16(uint8(B));
elseif strcmp(OriginalClass,'single')
    B = im2single(uint8(B));
else
    B = im2double(uint8(B));
end
end
