function [globalacc,classacc] = accuracy(confmat)
%ACCURACY Classification accuracy statistics.
%
%   GLOBALACC = ACCURACY(CONFMAT) computes the global accuracy, GLOBALACC,
%   for the classification described by the confusion matrix CONFMAT.
%   GLOBALACC is the total number of correctly classified examples divided
%   by the total number of examples. GLOBALACC is a scalar double in [0,1].
%
%   [___,CLASSACC] = ACCURACY(CONFMAT) also returns the class accuracy,
%   CLASSACC, which is the share of correctly classified examples in each
%   class. If N is the number of classes, CLASSACC is a vector of N doubles
%   in [0,1], where CLASSACC(i) is the accuracy for class i.
%
%   Notes
%   -----
%   [1] This function is meant for internal use only.
%
%   [2] CONFMAT must be a square matrix.
%
%   See also images.internal.segmentation.bwconfmat, jaccard, dice, bfscore.

%   Copyright 2017 The MathWorks, Inc.

% This function is used by evaluateSemanticSegmentation in CVST.

globalacc = sum(diag(confmat)) / sum(sum(confmat,2));

num_class = size(confmat,1);
classacc = zeros(num_class,1);
for i = 1:num_class
    classacc(i) = confmat(i,i) / sum(confmat(i,:));
end
