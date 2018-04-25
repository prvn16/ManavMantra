function confmat = bwconfmat(bwpred,bwtrue)
%BWCONFMAT Confusion matrix for multi-class pixel-level image segmentation.
%
%   CONFMAT = BWCONFMAT(PREDICTION,GROUNDTRUTH) computes the pixel-level
%   classification confusion matrix, CONFMAT, of a predicted segmentation
%   compared to a ground truth segmentation. PREDICTION and GROUNDTRUTH are
%   cell arrays, where each cell k contains a logical array representing a
%   binary segmentation for class k. CONFMAT is a square matrix, where
%   CONFMAT(i,j) is the number of pixels known to belong to class i but
%   predicted to belong to class j.
%
%   Note
%   ----
%   This function is meant for internal use only.
%
%   See also images.internal.segmentation.accuracy, jaccard, dice, bfscore.

%   Copyright 2017 The MathWorks, Inc.

% This function is used by evaluateSemanticSegmentation in CVST.

num_class = numel(bwpred);
confmat = zeros(num_class);
for j = 1:num_class
    for i = 1:num_class
        confmat(i,j) = nnz(bwpred{j} & bwtrue{i});
    end
end
