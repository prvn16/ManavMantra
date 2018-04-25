%% Fog Rectification
% This example demonstrates the use of image processing functions for GPU Code generation.
% The example takes a foggy image as input and produces a defogged image.
% This is a typical implementation of fog rectification algorithm. The example uses conv2, rgb2gray and imhist functions.
% See GPU Coder(TM) documentation for full list of supported functions.
%Copyright 2010-2017 The MathWorks, Inc.

%% Prerequisites
% * CUDA-enabled NVIDIA(R) GPU with compute capability 3.0 or higher.
% * NVIDIA CUDA toolkit.
% * Image Processing Toolbox
% * Environment variables for the compilers and libraries. For more 
% information see 
% <matlab:web(fullfile(docroot,'gpucoder/gs/setting-up-the-toolchain.html'))
% Environment Variables>.

%% Create a New Folder and Copy Relevant Files
% The following line of code creates a folder in your current working 
% folder (pwd), and copies all the relevant files into this folder. If you 
% do not want to perform this operation or if you cannot generate files in 
% this folder, change your current working folder.
gpucoderdemo_setup('gpucoderdemo_fog_rectification');


%% Verify the GPU Environment
% Use the <matlab:doc('coder.checkGpuInstall') coder.checkGpuInstall> function
% and verify that the compilers and libraries needed for running this example
% are set up correctly.
coder.checkGpuInstall('gpu','codegen','quiet');

%% About the 'fog_rectification' Function
% The <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_fog_rectification','fog_rectification.m')) fog_rectification.m>
% function takes foggy image as input and returns defogged image'. 
%
type fog_rectification

%% Generate CUDA code and MEX function
% Setup the input for code generation and create a configuration for GPU code
% generation.
inputImage = imread('foggyInput.png');
cfg = coder.gpuConfig('mex');

%% Run Code Generation
% Generate MEX 'fog_rectification_mex' by using codegen command.
codegen -args {inputImage} -config cfg fog_rectification -o fog_rectification_gpu_mex

%% Run the MEX Function with Foggy Image
% Run the generated fog_rectification_gpu_mex with a foggy input image, and plot
% the foggy and defogged images.
[outputImage] = fog_rectification_gpu_mex(inputImage);

% plot images
p1  = subplot(1, 2, 1);
p2 = subplot(1, 2, 2);
imshow(inputImage, 'Parent', p1);
imshow(outputImage, 'Parent', p2);
title(p1, 'Foggy Input Image');
title(p2, 'Defogged Output Image');

%% Cleanup
% Remove the temporary files and return to the original folder
%% Run Command: Cleanup
cleanup

displayEndOfDemoMessage(mfilename)
