function [matchedRefPoints,matchedQryPoints] = feature_matching(refPoints,refDesc,qryPoints,qryDesc) %#codegen

%   Copyright 2018 The MathWorks, Inc.

coder.gpu.kernelfun;

%% Feature Matching
[indexPairs,matchMetric] = matchFeatures(refDesc, qryDesc);
matchedRefPoints = refPoints(indexPairs(:,1),:);
matchedQryPoints = qryPoints(indexPairs(:,2),:);
