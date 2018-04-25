%% Feature Extraction using SURF
%
% Object Recognition using |Speeded-Up Robust Features| (SURF) is composed 
% of three steps - feature extraction, feature description, and feature matching.
% This example performs feature extraction, which is the first step of the
% SURF algorithm. The algorithm used here is based on the OpenSURF library implementation.
% In this example, we demonstrate how GPU Coder(TM) can be
% used to solve this compute intensive problem, through CUDA(R) code generation. 
%
% Copyright 2017 The MathWorks, Inc.
%% Prerequisites
%
% * CUDA(R)-enabled NVIDIA(R) GPU with compute capability 3.0 or higher.
% * Image Processing Toolbox(TM) for reading and displaying images.
% * NVIDIA CUDA toolkit.
% * Environment variables for the compilers and libraries. For more 
% information see 
% <matlab:web(fullfile(docroot,'gpucoder/gs/setting-up-the-toolchain.html'))
% Environment Variables>.

%% Create a New Folder and Copy Relevant Files
%
% The following line of code creates a folder in your current working folder (pwd), 
% and copies all the relevant files into this folder. If you do not want to perform 
% this operation or if you cannot generate files in this folder, change your 
% current working folder.
%%
%
gpucoderdemo_setup('gpucoderdemo_feature_extraction');

%% Verify the GPU Environment
% Use the <matlab:doc('coder.checkGpuInstall') coder.checkGpuInstall> function
% and verify that the compilers and libraries needed for running this example
% are set up correctly.
coder.checkGpuInstall('gpu','codegen','quiet');

%% Feature Extraction
%
% Feature extraction is a fundamental step in any object recognition algorithm. 
% It refers to the process of extracting useful information referred to as
% |features| from an input image. The extracted features need to be representative 
% in nature, carrying important and unique attributes of the image.
%
% The <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_feature_extraction','SurfDetect.m')) SurfDetect.m>
% function is the main entry-point, that performs feature extraction. 
% This function accepts an 8-bit RGB or an 8-bit grayscale image as the input. The output returned is an array 
% of extracted interest points. This function is composed of the following
% function calls, which contain computations suitable for GPU parallelization: 
%
% * <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_feature_extraction','Convert32bitFPGray.m')) Convert32bitFPGray.m>
% function converts an 8-bit RGB image to an 8-bit grayscale image. If the
% input provided is already in the 8-bit grayscale format, this step
% is skipped. After this, the 8-bit grayscale image is converted to a 32-bit
% floating-point representation for enabling fast computations on the GPU.
%
% * <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_feature_extraction','MyIntegralImage.m')) MyIntegralImage.m>
% function calculates the integral image of the 32-bit floating-point grayscale image
% obtained in the previous step. The integral image is useful for
% simplifying the operation of finding the sum of pixels enclosed within
% any rectangular region of the image. This helps in improving the speed of
% convolutions performed in the next step.
%
% * <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_feature_extraction','FastHessian.m')) FastHessian.m>
% function performs convolution of the image with box filters of different
% sizes and stores the computed responses. In this example, we use the
% following parameters:
%
%      Number of Octaves: 5
%
%      Number of Intervals: 4
%
%      Threshold: 0.0004
%
%      Filter Sizes: Octave 1 -  9,  15,  21,  27
%
%                    Octave 2 - 15,  27,  39,  51
%
%                    Octave 3 - 27,  51,  75,  99
%
%                    Octave 4 - 51,  99, 147, 195
%
%                    Octave 5 - 99, 195, 291, 387
%
% * <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_feature_extraction','NonMaxSuppression_gpu.m')) NonMaxSuppression_gpu.m>
% function performs non-maximal suppression to filter out only the useful
% interest points from the responses obtained above, based on a number of
% factors. We use the <matlab:doc('coder.ceval') coder.ceval> construct to generate a kernel that uses
% the |atomicAdd| operation. Since this construct is not compatible when
% invoked directly from MATLAB(R), we have 2 different function calls -
% <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_feature_extraction','NonMaxSuppression_gpu.m')) NonMaxSuppression_gpu.m> function gets invoked when GPU code generation
% is enabled and <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_feature_extraction','NonMaxSuppression.m')) NonMaxSuppression.m> gets invoked when we are executing
% the algorithm directly in MATLAB(R).
%
% * <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_feature_extraction','OrientationCalc.m')) OrientationCalc.m> 
% function calculates and assigns orientation to the interest points
% located in the previous step.
%
% The final result obtained is an array of interest points where an
% interest point is a structure that consists of the following fields: 
%
%      x, y (coordinates), scale, orientation, laplacian
%

%% Read Input Image
%
% Read an input image into MATLAB(R) by using the |imread| function.
%
imageFile = 'peppers.png';
inputImage = imread(imageFile);
imshow(inputImage);

%% Generate CUDA MEX for the Function
%
% To generate CUDA MEX for the |SurfDetect| function, create a GPU Coder(TM) configuration object and use the |codegen| function.
%
cfg = coder.gpuConfig('mex');
evalc('codegen -config cfg SurfDetect -args {inputImage}');

%% Run the MEX Function on a GPU
%
% The generated MEX function |SurfDetect_mex|, can be invoked to run on a
% GPU in the following way:
%
disp('Running GPU Coder SURF');
interestPointsGPU = SurfDetect_mex(inputImage);
fprintf('    GPU Coder SURF found: %d interest points\n',length(interestPointsGPU));

%% Depict the Extracted Interest Points
%
% The output |interestPointsGPU| is an array of extracted interest points. These interest points are depicted
% over the input image in a figure window.
%

DrawIpoints(imageFile, interestPointsGPU);

%% Cleanup
%
% Remove files, perform clean up and return to the original folder.
%%
%
cleanup

displayEndOfDemoMessage(mfilename)
%% References
% 
% # Notes on the OpenSURF Library by Christopher Evans
% # SURF: Speeded-Up Robust Features by Herbert Bay, Tinne Tuytelaars and Luc Van Gool
% 
