function [L, P] = imseggeodesic(varargin)
%IMSEGGEODESIC Segment image into two or three regions using geodesic distance-based color segmentation.
%
%   L = IMSEGGEODESIC(RGB, BW1, BW2) returns a segmented image with two
%   regions (binary segmentation) with region labels specified by label
%   matrix L. IMSEGGEODESIC uses a geodesic distance-based color
%   segmentation algorithm (similar to [1]) for segmentation. BW1 and BW2
%   are binary images that specify the location of the initial seed regions
%   or "scribbles" for the two regions (foreground and background). The
%   scribbles specified in BW1 and BW2 are used as representative samples
%   for computing the statistics for their respective regions, which are
%   then used in segmentation. BW1 and BW2 must have the same number of
%   rows and columns as RGB. The scribbles specified by BW1 and BW2
%   (regions that are logical true) should not overlap. Larger scribbles,
%   i.e., greater number of pixels marked as scribbles, lead to more
%   accurate segmentation.
%
%   L = IMSEGGEODESIC(RGB, BW1, BW2, BW3) returns a segmented image with
%   three regions (trinary segmentation) with the region labels specified
%   by label matrix L. BW1, BW2 and BW3 are binary images that specify the
%   location of the initial seed regions or "scribbles" for the three
%   regions. BW1, BW2 and BW3 must have the same number of rows and columns
%   as RGB. The scribbles specified by BW1, BW2 and BW3 (regions that are
%   logical true) should not overlap.
% 
%   [L, P] = IMSEGGEODESIC(___) returns the probability for each pixel
%   belonging to each of the labels in matrix P. P is a MxNx2 matrix for
%   binary segmentation and an MxNx3 matrix for trinary segmentation, where
%   M and N are the number of rows and columns in the input image RGB.
%   P(i,j,k) specifies the probability of pixel at location (i,j) belonging
%   to label k.
%
%   [L, P] = IMSEGGEODESIC(___, Name, Value,...) returns the label matrix L
%   using name-value pairs to control aspects of segmentation. Parameter
%   names can be abbreviated.
%
%   Parameters include:
%
%   'AdaptiveChannelWeighting' - Logical scalar that specifies whether
%                          various channels in the input image are weighted
%                          adaptively based on their content or not. When
%                          this parameter is set to true, the channels are
%                          weighted proportional to the amount of
%                          discriminatory information they have (based on
%                          the scribbles provided as input) that is useful
%                          for segmentation. When this parameter is set to
%                          false, all the channels are weighted equally.
%                          Default value is false.
%
%   Class Support 
%   ------------- 
%   The input array RGB must be a valid RGB image and must be of one of the
%   following classes: uint8, uint16, or double. BW1, BW2, BW3 must be
%   logical matrices. Output arrays L and P are of class double.
%
%   Notes
%   -----
%   1. Input image, RGB, is internally converted to YCbCr color space which
%      is then used for segmentation.
%   2. The underlying algorithm uses the statistics estimated over the
%      regions marked by the scribbles for segmentation. Greater number of
%      pixels marked by scribbles lead to more accurate estimation of the
%      region statistics, which typically leads to more accurate
%      segmentation. Therefore, it is a good practice to provide as many
%      scribbles as possible. Typically, at least a few hundred pixels need
%      to be provided as scribbles for each region.
%   3. The scribbles for the two (or three) regions should not overlap each
%      other, and each of them should be non-empty, i.e. there should be at
%      least one pixel (although the more the better) marked as logical
%      true in each of the scribbles.
%      
%   Example 1
%   ---------
%   This example segments an image into two regions (object and background)
%   using color information.
%
%     RGB = imread('yellowlily.jpg'); 
%     imshow(RGB,'InitialMagnification', 50), hold on
% 
%     % Specify the initial seed regions or "scribbles" for the foreground 
%     % object (flower)
%     bbox1 = [700 350 820 775]; % [left_topR left_topC bottom_rightR bottom_rightC]
%     BW1 = false(size(RGB,1),size(RGB,2));
%     BW1(bbox1(1):bbox1(3),bbox1(2):bbox1(4)) = true;
% 
%     % Specify the initial seed regions or "scribbles" for the background 
%     bbox2 = [1230 90 1420 1000];  
%     BW2 = false(size(RGB,1),size(RGB,2));
%     BW2(bbox2(1):bbox2(3),bbox2(2):bbox2(4)) = true;
% 
%     % Display seed regions
%     visboundaries(BW1,'Color','r');
%     visboundaries(BW2,'Color','b');
% 
%     % Segment the image
%     [L, P] = imseggeodesic(RGB, BW1, BW2);
% 
%     % Display results
%     figure, imshow(label2rgb(L),'InitialMagnification', 50)
%     title('Segmented image')
% 
%     figure, imshow(P(:,:,1),'InitialMagnification', 50)
%     title('Probability that a pixel belongs to the foreground')
%
%   Example 2
%   ---------
%   This example segments an image into three regions using color 
%   information.
%
%     RGB = imread('yellowlily.jpg'); 
%     imshow(RGB,'InitialMagnification', 50), hold on
% 
%     % Obtain scribbles for three regions. Note that you can specify the 
%     % scribbles interactively using tools such as roipoly, imfreehand, 
%     % imrect, impoly, and imellipse.
% 
%     % Region 1 (yellow flower)
%     region1 = [350 700 425 120]; % [x y w h] format
%     BW1 = false(size(RGB,1),size(RGB,2));
%     BW1(region1(2):region1(2)+region1(4),region1(1):region1(1)+region1(3)) = true;
% 
%     % Region 2 (green leaves) 
%     region2 = [800 1124 120 230];
%     BW2 = false(size(RGB,1),size(RGB,2));
%     BW2(region2(2):region2(2)+region2(4),region2(1):region2(1)+region2(3)) = true;
% 
%     % Region 3 (background)
%     region3 = [20 1320 480 200; 1010 290 180 240]; 
%     BW3 = false(size(RGB,1),size(RGB,2));
%     BW3(region3(1,2):region3(1,2)+region3(1,4),region3(1,1):region3(1,1)+region3(1,3)) = true;
%     BW3(region3(2,2):region3(2,2)+region3(2,4),region3(2,1):region3(2,1)+region3(2,3)) = true;
% 
%     % Display seed regions
%     visboundaries(BW1,'Color','r');
%     visboundaries(BW2,'Color','g');
%     visboundaries(BW3,'Color','b');
% 
%     % Segment the image
%     [L, P] = imseggeodesic(RGB, BW1, BW2, BW3, 'AdaptiveChannelWeighting', true);
% 
%     % Display results
%     figure, imshow(label2rgb(L),'InitialMagnification', 50)
%     title('Segmented image with three regions')
% 
%     figure, imshow(P(:,:,2),'InitialMagnification', 50)
%     title('Probability that a pixel belongs to region/label 2')
% 
%   References:
%   -----------
%   [1] A. Protiere and G. Sapiro, �Interactive Image Segmentation via
%       Adaptive Weighted Distances�, IEEE Transactions on Image
%       Processing, Volume 16, Issue 4, 2007. 
%
%   See also ACTIVECONTOUR, COLORTHRESHOLDER, IMSEGFMM, VISBOUNDARIES.

%   Copyright 2014-2017 The MathWorks, Inc.

narginchk(3,Inf);
varargin = matlab.images.internal.stringToChar(varargin);
[A, BW, options] = parse_inputs(varargin{:});

if isempty(A)    
    L = A;
    P = A;
    return;
end

A = double(rgb2ycbcr(A));

geodSegmenter = images.internal.CompetingRegionGeodesicSegmenter(A);
regionIdx = cell(size(BW,3),1);
for i = 1:size(BW,3)
    regionIdx{i} = find(BW(:,:,i));
    if isempty(regionIdx{i})
        error(message('images:CompetingRegionGeodesicSegmenter:emptyScribbles', ...
            ['BW' num2str(i)]));
    end
end
geodSegmenter = segment(geodSegmenter, regionIdx, ...
                                  options.AdaptiveChannelWeighting);

L = geodSegmenter.L;
if nargout > 1
    P = geodSegmenter.alphamat;
end

end


function [A, BW, options] = parse_inputs(varargin)

validImageTypes = {'uint8','uint16','double'};

A = varargin{1};
validateattributes(A,validImageTypes,{'nonsparse','real','3d','finite'}, ... 
    mfilename,'A',1);
if (~isempty(A) && size(A,3) ~= 3)
    error(message('images:validate:invalidRGBImage','A'));
end

sizeA = [size(A,1) size(A,2)]; 

BW = false([sizeA 2]);

BWtemp = varargin{2};
validateattributes(BWtemp,{'numeric','logical'},{'nonsparse','real','2d','nonnan'}, ... 
    mfilename,'BW1',2);
if isequal(size(BWtemp),sizeA)
    BW(:,:,1) = logical(BWtemp);
else
    error(message('images:validate:unequalNumberOfRowsAndCols','A','BW1'));
end    

BWtemp = varargin{3};
validateattributes(BWtemp,{'numeric','logical'},{'nonsparse','real','2d','nonnan'}, ... 
    mfilename,'BW2',2);
if isequal(size(BWtemp),sizeA)
    BW(:,:,2) = logical(BWtemp);
else
    error(message('images:validate:unequalNumberOfRowsAndCols','A','BW2'));
end
    
first_string = min(find(cellfun(@ischar, varargin), 1, 'first'));
if isempty(first_string)
    first_string = length(varargin) + 1;
end

if (first_string ~= 4) && (first_string ~= 5)
    % Neither imseggeodesic(A, BW1, BW2,____) nor imseggeodesic(A, BW1, BW2, BW3,____)
    error(message('images:validate:invalidSyntax'))
    
else
    if (first_string == 5)
        % imseggeodesic(A, BW1, BW2, BW3,____)
        BWtemp = varargin{4};
        validateattributes(BWtemp,{'numeric','logical'},{'nonsparse','real','2d','nonnan'}, ...
            mfilename,'BW3',2);
        if isequal(size(BWtemp),sizeA)
            BW(:,:,3) = logical(BWtemp);
        else
            error(message('images:validate:unequalNumberOfRowsAndCols','A','BW3'));
        end        
    end
    
end

% Check for overlapping scribbles
validateScribbles(BW);

% Handle remaining name-value pair parsing
name_value_pairs = varargin(first_string:end);
num_pairs = numel(name_value_pairs);
if (rem(num_pairs, 2) ~= 0)
    error(message('images:validate:missingParameterValue'));
end

args_names = {'AdaptiveChannelWeighting'};
arg_default_values = {0, false};

% Set default parameter values
for i = 1: numel(args_names)
    options.(args_names{i}) = arg_default_values{i};
end

for i = 1:2:num_pairs
    arg = name_value_pairs{i};
    if ischar(arg)        
        idx = find(strncmpi(arg, args_names, numel(arg)));
        if isempty(idx)
            error(message('images:validate:unknownInputString', arg))
        elseif numel(idx) > 1
            error(message('images:validate:ambiguousInputString', arg))
        elseif numel(idx) == 1            
            options.(args_names{idx}) = name_value_pairs{i+1};
        end    
    else
        error(message('images:validate:mustBeString')); 
    end
end

% Validate AdaptiveChannelWeighting value. 
validateattributes(options.AdaptiveChannelWeighting, {'numeric','logical'}, ...
    {'scalar','nonempty','nonsparse','real','nonnan'}, mfilename,'AdaptiveChannelWeighting');
options.AdaptiveChannelWeighting = logical(options.AdaptiveChannelWeighting);

end    

function validateScribbles(BW)
sumBW = sum(BW,3);
if any(sumBW(:) > 1)
    if size(BW,3) == 2
        variableString = 'BW1 and BW2';
    else
        variableString = 'BW1, BW2, and BW3';
    end
    error(message('images:CompetingRegionGeodesicSegmenter:overlappingScribbles', ...
        variableString));
end

end