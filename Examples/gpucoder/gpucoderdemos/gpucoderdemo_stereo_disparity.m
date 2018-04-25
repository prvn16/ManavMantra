%% Stereo Disparity
%
% This example shows how to generate a MEX function from a MATLAB 
% function that computes the stereo disparity of two images.
%
%   Copyright 2017 The MathWorks, Inc.
%% Prerequisites
% * CUDA-enabled NVIDIA(R) GPU with compute capability 3.0 or higher.
% * NVIDIA CUDA toolkit.
% * Environment variables for the compilers and libraries. For more
% information see
% <matlab:web(fullfile(docroot,'gpucoder/gs/setting-up-the-toolchain.html'))
% Environment Variables>.

%% Create a New Folder and Copy Relevant Files
% The following line of code creates a folder in your current working
% folder (pwd), and copies all the relevant files into this folder. If you
% do not want to perform this operation or if you cannot generate files in
% this folder, change your current working folder.
gpucoderdemo_setup('gpucoderdemo_stereo_disparity');

%% Verify the GPU Environment
% Use the <matlab:doc('coder.checkGpuInstall') coder.checkGpuInstall> function
% and verify that the compilers and libraries needed for running this example
% are set up correctly.
coder.checkGpuInstall('gpu','codegen','quiet');

%% Stereo Disparity Calculation
% The 
% <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_stereo_disparity','stereoDisparity.m'))
% stereoDisparity.m>
% function takes two images and returns a stereo disparity map computed from the two images.

type stereoDisparity

%% Read Images and Pack Data Into RGBA Packed Column Major Order
img0 = imread('scene_left.png');
img1 = imread('scene_right.png');

[imgRGB0] = pack_rgbData(img0);
[imgRGB1] = pack_rgbData(img1);

%% Left Image
% 
% <<scene_left.png>>

%% Right Image
%
% <<scene_right.png>>
%

%% Generate GPU Code
cfg = coder.gpuConfig('mex');
codegen -config cfg -args {imgRGB0, imgRGB1} stereoDisparity;

%% Run Generated MEX and Show the Output Disparity
out_disp = stereoDisparity_mex(imgRGB0,imgRGB1);
imagesc(out_disp);

%% Cleanup
% Remove files and return to original folder
%% Run Command: Cleanup
cleanup

displayEndOfDemoMessage(mfilename)
