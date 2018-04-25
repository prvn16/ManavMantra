function [score,precision,recall] = bfscore(prediction,groundtruth,varargin)
%BFSCORE Contour matching score for image segmentation.
%
%   SCORE = BFSCORE(PREDICTION,GROUNDTRUTH) computes the BF (Boundary F1)
%   contour matching score between the predicted segmentation in PREDICTION
%   and the true segmentation in GROUNDTRUTH.  PREDICTION and GROUNDTRUTH
%   can be a pair of logical arrays for binary segmentation, or a pair of
%   label or categorical arrays for multi-class segmentation.  SCORE is a
%   vector of doubles in [0,1], where the first coefficient is the BF score
%   for the first foreground class, the second for the second foreground
%   class, and so on.  A score of 1 means that the contours of objects in
%   the corresponding class in PREDICTION and GROUNDTRUTH are a perfect match.
%
%   [___,PRECISION,RECALL] = BFSCORE(PREDICTION,GROUNDTRUTH) also returns
%   the precision and recall values for the PREDICTION image compared to
%   the GROUNDTRUTH image.
%
%   [___] = BFSCORE(___,THRESHOLD) computes the BF score using a specified
%   THRESHOLD as the distance error tolerance to decide whether a boundary
%   point has a match or not.  If THRESHOLD is not specified, its default
%   value is 0.75% of the image diagonal.
%
%   Notes
%   -----
%   [1] PREDICTION and GROUNDTRUTH can be 2-D or 3-D.
%
%   [2] A valid label image is an array of non-negative integers of class
%   double.
%
%   [3] The BF (Boundary F1) score measures how close the predicted
%   boundary of an object matches the ground truth boundary. It is defined
%   as the harmonic mean of the precision and recall values (i.e.,
%   F1-measure) with a distance error tolerance to decide whether a point
%   on the predicted boundary has a match on the ground truth boundary or
%   not.
%
%     BF = 2 * PRECISION * RECALL / (RECALL + PRECISION)
%
%   [4] The precision is the ratio of the number of points on the boundary
%   of the predicted segmentation that are close enough to the boundary of
%   the ground truth segmentation to the length of the predicted boundary,
%   i.e., precision is the fraction of detections that are true positives
%   rather than false positives.
%
%   [5] The recall is the ratio of the number of points on the boundary of
%   the ground truth segmentation that are close enough to the boundary of
%   the predicted segmentation to the length of the ground truth boundary,
%   i.e., recall is the fraction of true positives that are detected rather
%   than missed.
%
%
%   Reference
%   ---------
%   Csurka, Gabriela, et al. "What is a good evaluation measure for
%   semantic segmentation?." BMVC. Vol. 27. 2013.
%
%   Example 1
%   ---------
%   Compute the BF score for a binary segmentation.
%
%     % Read in an image with an object we wish to segment.
%     A = imread('hands1.jpg');
%
%     % Convert the image to grayscale.
%     I = rgb2gray(A);
%
%     % Use active contours to segment the hand.
%     mask = false(size(I));
%     mask(25:end-25,25:end-25) = true;
%     BW = activecontour(I, mask, 300);
%
%     % Read in the ground truth against which to compare the segmentation.
%     BW_groundTruth = imread('hands1-mask.png');
%
%     % Compute the BF score of this segmentation.
%     score = bfscore(BW, BW_groundTruth);
%
%     % Display both masks on top of one another.
%     figure
%     imshowpair(BW, BW_groundTruth)
%     title(['BF score = ' num2str(score)])
%
%   Example 2
%   ---------
%   Compute the BF score for n-ary semantic segmentation.
%
%     % Read in an image with several objects we wish to segment.
%     RGB = imread('yellowlily.jpg');
%
%     % Create scribbles for three regions.
%     region1 = [350 700 425 120]; % [x y w h] format
%     BW1 = false(size(RGB,1),size(RGB,2));
%     BW1(region1(2):region1(2)+region1(4),region1(1):region1(1)+region1(3)) = true;
%  
%     region2 = [800 1124 120 230];
%     BW2 = false(size(RGB,1),size(RGB,2));
%     BW2(region2(2):region2(2)+region2(4),region2(1):region2(1)+region2(3)) = true;
%  
%     region3 = [20 1320 480 200; 1010 290 180 240]; 
%     BW3 = false(size(RGB,1),size(RGB,2));
%     BW3(region3(1,2):region3(1,2)+region3(1,4),region3(1,1):region3(1,1)+region3(1,3)) = true;
%     BW3(region3(2,2):region3(2,2)+region3(2,4),region3(2,1):region3(2,1)+region3(2,3)) = true;
%
%     % Display the seed regions on top of the image.
%     figure
%     imshow(RGB)
%     hold on
%     visboundaries(BW1,'Color','r');
%     visboundaries(BW2,'Color','g');
%     visboundaries(BW3,'Color','b');
%     title('Seed regions')
%
%     % Segment the image into three regions using
%     % geodesic distance-based color segmentation.
%     L = imseggeodesic(RGB,BW1,BW2,BW3,'AdaptiveChannelWeighting',true);
%
%     % Load a ground truth segmentation of the image into three regions.
%     L_groundTruth = double(imread('yellowlily-segmented.png'));
%
%     % Visually compare the segmentation results with the ground truth.
%     figure
%     imshowpair(label2rgb(L),label2rgb(L_groundTruth),'montage')
%     title('Comparison of segmentation results (left) and ground truth (right)')
%
%     % Compute the BF score for each segmented region.
%     score = bfscore(L, L_groundTruth)
%
%   See also DICE, JACCARD.

%   Copyright 2017 The MathWorks, Inc.

narginchk(2,3);

validateInput = @(x,name,pos) validateattributes(x, ...
    {'logical','double','categorical'}, ...
    {'real','nonempty','nonsparse','3d'}, ...
    mfilename,name,pos);

validateInput(prediction,'PREDICTION',1);
validateInput(groundtruth,'GROUNDTRUTH',2);

if any(size(prediction) ~= size(groundtruth))
    error(message('images:validate:unequalSizeMatrices', ...
        'PREDICTION','GROUNDTRUTH'))
end

if ~isa(prediction,class(groundtruth))
    error(message('images:validate:differentClassMatrices', ...
        'PREDICTION','GROUNDTRUTH'))
end

if isa(prediction,'double')
    % Additional validation for label matrices
    validateLabelMatrix = @(x,name,pos) validateattributes(x, ...
        {'double'}, ...
        {'finite','nonnegative','integer'}, ...
        mfilename,name,pos);
    validateLabelMatrix(prediction,'PREDICTION',1);
    validateLabelMatrix(groundtruth,'GROUNDTRUTH',2);
end

if isa(prediction,'categorical')
    % Additional validation for categorical matrices
    if ~isequal(categories(prediction),categories(groundtruth))
        error(message('images:segmentation:nonIdenticalCategories2', ...
            'PREDICTION','GROUNDTRUTH'))
    end
end

is2D = ismatrix(prediction);

if (nargin > 2)
    theta = varargin{1};
    validateattributes(theta, ...
        {'double'}, ...
        {'real','positive','nonnan'}, ...
        mfilename,'THRESHOLD',3);
else
    % 0.75% of the diagonal
    if is2D
        theta = 0.75 / 100 * sqrt(size(prediction,1)^2 + size(prediction,2)^2);
    else
        theta = 0.75 / 100 * sqrt(size(prediction,1)^2 + size(prediction,2)^2 + size(prediction,3)^2);
    end
end

% F1 measure = precision and recall are equally weighted
alpha = 0.5;

if is2D
    bwbfscore = @images.internal.segmentation.bwbfscore2;
else
    bwbfscore = @images.internal.segmentation.bwbfscore3;
end

if isa(prediction,'logical')
    % binary segmentation
    [score,precision,recall] = bwbfscore(prediction,groundtruth,theta,alpha);
else
    if isa(prediction,'categorical')
        % categorical matrices
        classes = categories(prediction);
    else
        % label matrices
        classes = (1:max(max(prediction(:)),max(groundtruth(:))))';
    end
    
    pred_bw = images.internal.segmentation.convertToCellOfLogicals(prediction,classes);
    true_bw = images.internal.segmentation.convertToCellOfLogicals(groundtruth,classes);
    
    num_class = numel(classes);
    score = zeros(num_class,1);
    precision = zeros(num_class,1);
    recall = zeros(num_class,1);
    for k = 1:num_class
        [score(k),precision(k),recall(k)] = ...
            bwbfscore(pred_bw{k},true_bw{k},theta,alpha);
    end
end
