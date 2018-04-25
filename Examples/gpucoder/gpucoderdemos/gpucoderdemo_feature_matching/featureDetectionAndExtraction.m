function [refPoints,refDesc,qryPoints,qryDesc] = featureDetectionAndExtraction(refImage, qryImage)

%   Copyright 2018 The MathWorks, Inc.

%% Extract features from both the images and find matching points
% SURF Feature Detection
refPointsStruct = detectSURFFeatures(refImage, 'MetricThreshold', 300);
qryPointsStruct = detectSURFFeatures(qryImage, 'MetricThreshold', 300);

% SURF Feature Extraction
refDesc = extractFeatures(refImage, refPointsStruct, 'FeatureSize', 128);
qryDesc = extractFeatures(qryImage, qryPointsStruct, 'FeatureSize', 128);

refPoints = refPointsStruct.Location; % Extract coordinate locations from SURFPoints structure
qryPoints = qryPointsStruct.Location; % Extract coordinate locations from SURFPoints structure
