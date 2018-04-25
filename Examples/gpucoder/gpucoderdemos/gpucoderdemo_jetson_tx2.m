%% Running an Embedded Application on the NVIDIA(R) Jetson TX2 Developer Kit
% This example shows how to generate CUDA(R) code from a SeriesNetwork object
% and target the NVIDIA's TX2 board with an external camera. This example
% uses the AlexNet deep learning network to classify images from a USB
% webcam video stream. 
%
%   Copyright 2017 The MathWorks, Inc.
%% Prerequisites
% * Neural Network Toolbox(TM) to load the SeriesNetwork object.
% * NVIDIA Jetson TX2 developer kit.
% * USB camera to connect to the TX2.
% * NVIDIA CUDA toolkit installed on the TX2.
% * NVIDIA cuDNN 5.0 library installed on the TX2.
% * OpenCV 3.3.0 libraries for video read and image display operations
% installed on the TX2.
% * OpenCV header and library files should be in the NVCC compiler search
% path of the TX2.
% * Environment variables for the compilers and libraries. For information 
% on the supported versions of the compilers and libraries, see 
% <matlab:web(fullfile(docroot,'gpucoder/gs/install-prerequisites.html'))
% Third-party Products>. For setting up the environment variables, see 
% <matlab:web(fullfile(docroot,'gpucoder/gs/setting-up-the-toolchain.html'))
% Environment Variables>.
% * This demo is supported on Linux(R) platform only.

%% Verify the GPU Environment for Target Hardware
% Use the <matlab:doc('coder.checkGpuInstall') coder.checkGpuInstall> function
% and verify that the compilers and libraries needed for running this example
% are set up correctly.
coder.checkGpuInstall('tx2','quiet');
%% Create a New Folder and Copy Relevant Files
% The following line of code creates a folder in your current working 
% folder (pwd), and copies all the relevant files into this folder. If you 
% do not want to perform this operation or if you cannot generate files in 
% this folder, change your current working folder.
gpucoderdemo_setup('gpucoderdemo_jetson_tx2');

%% Get the Pre-trained SeriesNetwork
% AlexNet contains 25 layers including convolution, fully connected and the
% classification output layers.
net = getAlexnet();
disp(net.Layers);

%% Generate Code for the SeriesNetwork
% Generate code for the TX2 platform.

cfg = coder.gpuConfig('lib');
cfg.GenerateReport = true;
cfg.TargetLang = 'C++';
cfg.Toolchain = 'NVIDIA CUDA for Jetson Tegra X2 | gmake (64-bit Linux)';
cfg.HardwareImplementation.TargetHWDeviceType = 'Generic->Custom';

codegen -config cfg -args {ones(227,227,3,'single'), coder.Constant('alexnet.mat')} alexnet_predict.m

%%
% A warning is thrown regarding non-coalesced access to input variable.
% This is because the |codegen| command generates column major code. This needs
% to be transposed to row-major format to call the underlying cuDNN
% library. To avoid this transpose, use the 
% <matlab:doc('cnncodegen') cnncodegen command>
% for standalone code generation. This generates row-major code without any
% transposes.

%% Generated Code Description
% 
% The generated code is compiled into a static library alexnet_predict.a. 
%
% The generated code includes code for entry-point design file, network
% classes and binary weight files containing the network coefficients.


dir(fullfile('codegen', 'lib', 'alexnet_predict'))
%% Main File 
% The custom main file creates and sets up the network object with 
% layers and weights. It uses the OpenCV VideoCapture method to 
% read frames from a camera connected to the TX2. 
% Each frame is processed and classified, 
% until no more frames are to be read.

edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_jetson_tx2', 'main_webcam.cu'));

%% Copy Files to the Codegen Directory
% Copy the files required for the executable.

copyfile('create_exe.mk', fullfile('codegen', 'lib', 'alexnet_predict', 'create_exe.mk'));
copyfile('synsetWords.txt', fullfile('codegen', 'lib', 'alexnet_predict', 'synsetWords.txt'));
copyfile('main_webcam.cu', fullfile('codegen', 'lib', 'alexnet_predict', 'main_webcam.cu'));
copyfile('maxperf.sh', fullfile('codegen', 'lib', 'alexnet_predict', 'maxperf.sh'));

%% Build and Run on Target Hardware
% Copy the codegen folder to a directory in the TX2.
%
%   scp -r ./codegen/lib/alexnet_predict username@jetson-tx2-name:/path/to/desired/location
%
% On the TX2, navigate to the copied codegen directory and execute the
% following commands.
%
%   sudo ./maxperf.sh
%
% The maxperf.sh script is used to boost TX2 performance.
%% 
% Run make to generate an executable using the main file, the static library alexnet_predict.a and OpenCV libraries.
%%
%   make -f create_exe.mk
% 
% Run the executable on the TX2 platform with a device number for your webcam.
%
%   ./alexnet_exe 1
%
% This displays a live video feed from the webcam accompanied by the
% AlexNet predictions of the current image. Press escape at any time to
% quit.
%% AlexNet Classification Output on TX2
% <<gpucoderdemo_jetson_tx2_alexnet_screenshot.png>>
%% Cleanup
% Remove files and return to original folder.

cleanup

displayEndOfDemoMessage(mfilename)
