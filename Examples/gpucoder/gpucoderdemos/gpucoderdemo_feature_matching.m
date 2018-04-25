%% Feature Matching
% This example shows how to generate CUDA(R) MEX from MATLAB(R) code and 
% perform feature matching between two images. This example uses the 
% |matchFeatures| function from the Image Processing Toolbox(TM) to match
% the feature descriptors between two images that are rotated and scaled 
% with respect to each other. The feature descriptors of the two images 
% are detected and extracted by using the Speeded-Up Robust Features 
% (SURF) algorithm.
% See GPU Coder(TM) documentation for full list of supported functions.
%Copyright 2010-2018 The MathWorks, Inc.

%% Prerequisites
% * CUDA(R) enabled NVIDIA(R) GPU with compute capability 3.2 or higher.
% * NVIDIA CUDA toolkit and driver.
% * Environment variables for the compilers and libraries. For information 
% on the supported versions of the compilers and libraries, see 
% <matlab:web(fullfile(docroot,'gpucoder/gs/install-prerequisites.html'))
% Environment Variables>.
% * Computer Vision System Toolbox(TM) for the video reader and viewer 
% used in the example.
% * Image Processing Toolbox(TM) for reading and displaying images.
% * This example is supported only on the Linux® platform.

%% Create a New Folder and Copy Relevant Files
% The following line of code creates a folder in your current working 
% folder (pwd), and copies all the relevant files into this folder. If you 
% do not want to perform this operation or if you cannot generate files in 
% this folder, change your current working folder.
gpucoderdemo_setup('gpucoderdemo_feature_matching');


%% Verify the GPU Environment
% Use the <matlab:doc('coder.checkGpuInstall') coder.checkGpuInstall> function
% and verify that the compilers and libraries needed for running this example
% are set up correctly.
coder.checkGpuInstall('gpu','codegen','quiet');

%% Feature Detection and Extraction
% For this example, feature matching is performed on two images that are 
% rotated and scaled with respect to each other.
% Before the two images can be matched, feature points for each image must 
% be detected and extracted. The following 
% <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_feature_matching','featureDetectionAndExtraction.m')) featureDetectionAndExtraction>
% function uses SURF (|detectSURFFeatures|) local feature detector to 
% detect the feature points and |extractFeatures| to extract the features.

% The function |featureDetectionAndExtraction| returns |refPoints|, which
% contains the feature coordinates of the reference image, |qryPoints|,
% containing feature coordinates of query image, |refDesc| matrix
% containing reference image feature descriptors and |qryDesc| matrix
% containing query image feature descriptors.

% refPoints = Reference image feature coordinates.
% qryPoints = Query image feature coordinates.
% refDescFeat = Reference image feature descriptors
% qryDescFeat = Query image feature descriptors

% Read Image
K = imread('cameraman.tif'); % Reference image
refImage = imresize(K,3);

scale = 0.7;  % Scaling the image.
J = imresize(refImage, scale);
theta = 30.0;   % Rotating the image
qryImage = imrotate(J,theta); % Query image

[refPoints,refDescFeat,qryPoints,qryDescFeat] = featureDetectionAndExtraction(refImage, qryImage);

%% About the 'feature_matching' Function
% The <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_feature_matching','feature_matching.m')) feature_matching>
% function takes feature points and feature descriptors extracted from two
% images and finds a match among them.
type feature_matching

%% Feature Matching Codegen
% Since the demo runs on the host system, creating a MEX-call configuration
% object with default parameters. Enabling safe-build option to avoid
% abnormal termination of MATLAB in case of run-time errors in the
% generated code.
cfg = coder.gpuConfig;
cfg.GpuConfig.SafeBuild = 1;
codegen -config cfg -args {refPoints,refDescFeat,qryPoints,qryDescFeat} feature_matching -o feature_matching_gpu_mex
[matchedRefPoints_gpu,matchedQryPoints_gpu] = feature_matching_gpu_mex(refPoints,refDescFeat,qryPoints,qryDescFeat);

%%
% A note is thrown regarding a loop not perfectly nested. Since, the output
% matched point's array size is varies at runtime, therefore an conditional
% array copy generates an imperfect loop, which is not mapped to the GPU
% and so cannot be parallelized.

% Display feature matches
figure;
showMatchedFeatures(refImage, qryImage, matchedRefPoints_gpu, matchedQryPoints_gpu);
title('Putatively matched points (including outliers)');

%% Cleanup
% Remove the temporary files and return to the original folder
%% Run Command: Cleanup
cleanup

displayEndOfDemoMessage(mfilename)
