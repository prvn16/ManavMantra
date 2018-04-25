function similarity = dice(A,B)
%DICE Sorensen-Dice similarity coefficient for image segmentation.
%
%   SIMILARITY = DICE(BW1,BW2) computes the Sorensen-Dice similarity
%   coefficient between segmented objects in binary images BW1 and BW2.
%   SIMILARITY is a scalar double in [0,1]. A SIMILARITY of 1 means that
%   the segmentations in BW1 and BW2 are a perfect match.
%
%   SIMILARITY = DICE(L1,L2) computes the Dice index for each label
%   in label images L1 and L2.  SIMILARITY is a vector of doubles in [0,1],
%   where the first coefficient is the Dice index for label 1, the
%   second for label 2, and so on.
%
%   SIMILARITY = DICE(C1,C2) computes the Dice index for each
%   category in categorical images C1 and C2.  SIMILARITY is a vector of
%   doubles in [0,1], where the first coefficient is the Dice index for
%   the first category, the second index for the second category, and so on.
%
%   Notes
%   -----
%   [1]  The Dice similarity coefficient of two sets A and B is
%   expressed as
%
%      dice(A,B) = 2 * |intersection(A,B)| / (|A| + |B|)
%
%   where |A| represents the cardinal of set A. It can also be expressed in
%   terms of true positives (TP), false positives (FP) and false negatives
%   (FN) as
%
%      dice(A,B) = 2 * TP / (2 * TP + FP + FN)
%
%   [2]  The Dice index is related to the Jaccard index according to
%
%      dice(A,B) = 2 * jaccard(A,B) / (1 + jaccard(A,B))
%
%   [3]  The inputs BW, L and C can be 2-D or 3-D arrays.
%
%   Example 1
%   ---------
%   Compute the Dice similarity coefficient for a binary segmentation.
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
%     % Compute the Dice index of this segmentation.
%     similarity = dice(BW, BW_groundTruth);
%
%     % Display both masks on top of one another.
%     figure
%     imshowpair(BW, BW_groundTruth)
%     title(['Dice index = ' num2str(similarity)])
%
%   Example 2
%   ---------
%   Compute the Dice similarity coefficient for n-ary segmentation.
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
%     % Compute the Dice similarity index
%     % for each segmented region.
%     similarity = dice(L, L_groundTruth)
%
%   See also BFSCORE, JACCARD.

%   Copyright 2017 The MathWorks, Inc.

try
    jac = jaccard(A,B);
catch ME
    throw(ME)
end

similarity = 2 * jac ./ (1 + jac);
