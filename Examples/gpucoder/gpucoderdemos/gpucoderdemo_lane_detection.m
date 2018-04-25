%% Lane Detection Optimized With GPU Coder
% 
% This example shows how to generate CUDA(R) code from a deep learning network, which is
% represented by a SeriesNetwork object.
% The SeriesNetwork in this example is a convolutional neural network that can 
% detect and output lane marker boundaries from image.
%
%   Copyright 2017-2018 The MathWorks, Inc.
%% Prerequisites
% * CUDA(R) enabled NVIDIA(R) GPU with compute capability 3.2 or higher.
% * NVIDIA CUDA toolkit and driver.
% * NVIDIA cuDNN library (v7).
% * OpenCV 3.1.0 libraries for video read and image display operations.
% * Environment variables for the compilers and libraries. For information 
% on the supported versions of the compilers and libraries, see 
% <matlab:web(fullfile(docroot,'gpucoder/gs/install-prerequisites.html'))
% Third-party Products>. For setting up the environment variables, see 
% <matlab:web(fullfile(docroot,'gpucoder/gs/setting-up-the-toolchain.html'))
% Environment Variables>.
% * Neural Network Toolbox(TM) for using SeriesNetwork objects.
%% Verify the GPU Environment
% Use the <matlab:doc('coder.checkGpuInstall') coder.checkGpuInstall> function
% and verify that the compilers and libraries needed for running this example
% are set up correctly.
coder.checkGpuInstall('gpu','codegen','cudnn','quiet');
%% Create a New Folder and Copy Relevant Files
% The following line of code creates a folder in your current working
% folder (pwd), and copies all the relevant files into this folder. If you
% do not want to perform this operation or if you cannot generate files in
% this folder, change your current working folder.
gpucoderdemo_setup('gpucoderdemo_lane_detection');

%% Get the Pre-Trained SeriesNetwork
[laneNet, coeffMeans, coeffStds] = getLaneDetectionNetwork();

%%
% This network takes image as an input and outputs 2 lane boundaries that 
% correspond to the ego vehicle's left and right lanes.
% Each lane boundary is given by a parabolic equation : 
% y = ax^2 + bx + c
% where y is the lateral offset and x is the longitudinal distance from the vehicle.
% The network outputs the 3 parameters a,b,c per lane.
% The network architecture is very similar to AlexNet,
% except that the last few layers have been replaced by a smaller fully
% connected layer and regression output layer.
disp(laneNet.Layers);

%% Examine Main Entry Point Function
type detect_lane.m

%% Generate Code for Network and Post Processing Code
%
% The network computes parameters a, b, and c describing the parabolic equation
% for the left and right lane boundaries. 
%
% From these parameters we can compute the x and y coordinates corresponding
% to the lane positions. Further, the coordinates need to be mapped to 
% image coordinates. The function detect_lane.m does all these computation.
% We can generate CUDA code from this functions as well.
%
cfg = coder.gpuConfig('lib');
cfg.GenerateReport = true;
cfg.TargetLang = 'C++';
codegen -args {ones(227,227,3,'single'),ones(1,6,'double'),ones(1,6,'double')} -config cfg detect_lane

%%
% A warning is thrown regarding non-coalesced access to input data variable.
% This is because the |codegen| command generates column-major code. This needs
% to be transposed to row-major format to call the underlying cuDNN
% library. To avoid this transpose, use the 
% <matlab:doc('cnncodegen') cnncodegen command>
% for standalone code generation. This generates row-major code without any
% transposes.


%% Generated Code Description
% The SeriesNetwork is generated as a C++ class containing an array of 23 layer
% classes.
%
%   class c_lanenet
%   {
%    public:
%     int32_T batchSize;
%     int32_T numLayers;
%     real32_T *inputData;
%     real32_T *outputData;
%     MWCNNLayer *layers[23];
%    public:
%     c_lanenet(void);
%     void setup(void);
%     void predict(void);
%     void cleanup(void);
%     ~c_lanenet(void);
%   };
%
% The setup() method of the class sets up handles and allocates memory for
% each layer object.
% The predict() method invokes prediction for each of the 23 layers in the network.
%
% The files cnn_lanenet_conv*_w and cnn_lanenet_conv*_w are the
% binary weights and bias file for convolution layer in the network.
% The files cnn_lanenet_fc*_w and cnn_lanenet_fc*_b are the
% binary weights and bias file for fully connected layer in the network.
%
codegendir = fullfile('codegen', 'lib', 'detect_lane');
dir(codegendir)

%% Generate Additional Files Needed for Post Processing Output
%
%   % export mean and std values from the trained network for use in testing
%   codegendir = fullfile(pwd, 'codegen', 'lib','detect_lane');
%   fid = fopen(fullfile(codegendir,'mean.bin'), 'w');
%   A = [coeffMeans coeffStds];
%   fwrite(fid, A, 'double');
%   fclose(fid);

%% Main File
% The network code is to be compiled with a main file.

%%
% The main file uses the OpenCV VideoCapture method to 
% read frames from the input video. Each frame is processed and classified, 
% until no more frames are to be read.
% Before displaying the output for each frame, the outputs are
% post-processed using the detect_lane function generated in
% detect_lane.cpp.

type main_lanenet.cpp

%% Download Example Video
%
%   if ~exist('./caltech_cordova1.avi', 'file')
%   	url = 'https://www.mathworks.com/supportfiles/gpucoder/media/caltech_cordova1.avi';
%   	websave('caltech_cordova1.avi', url);
%   end

%% Build Executable
%
%   if ispc
%       setenv('MATLAB_ROOT', matlabroot);
%       vspath = mex.getCompilerConfigurations('C++').Location;      
%       setenv('VSPATH', vspath);
%       system('make_win.bat');
%       cd(codegendir);
%       system('lanenet.exe ..\..\..\caltech_cordova1.avi');
%   else
%       setenv('MATLAB_ROOT', matlabroot);
%       system('make -f Makefile.mk');
%       cd(codegendir);
%       system('./lanenet ../../../caltech_cordova1.avi');
%   end

%% Input Screenshot
%%
% 
% <<lane_detect_input.png>>
% 

%% Output Screenshot
%%
% 
% <<lane_detect_output.png>>
% 


%% Cleanup
% Remove files and return to original folder
%% Run Command: Cleanup
cleanup

displayEndOfDemoMessage(mfilename)