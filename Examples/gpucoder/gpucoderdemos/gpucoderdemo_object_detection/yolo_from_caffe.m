%% Code generation from YOLO caffe model
% 
% This example shows how to generate CUDA code from a Series Network object
% created for YOLO architecture trained for classifying the PASCAL dataset

%   Copyright 2017 The MathWorks, Inc.

% YOLO is an object detection network that can classify objects in an image frame
% as well as the position of these objects. 
% Reference : 
% You Only Look Once: Unified, Real-Time Object Detection
% (Joseph Redmon, Santosh Divala and others)

% See link below for a demo of YOLO running on video feed
% https://www.dropbox.com/s/s995hs75cgrzs0a/Demo%208%20-%20YOLO%20on%20video%20feed.mp4?dl=0
%% Pre-requisites:
% Neural network toolbox to generate the Series Network object
% CUDA®-enabled NVIDIA® GPU with compute capability 3.0 or higher.
% g++
% CUDNN 5.0 
% OpenCV 2.4.9 for image read and display operations
%% Environment variables: 
% Windows: 
% CUDA_PATH            Path to the CUDA toolkit installation. 
%                      By default, C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v8.0\
% NVIDIA_CUDNN         Path to the root folder of cuDNN installation.
%                      For example, C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\cuDNN
%
% Linux:
% PATH                 Path to the CUDA toolkit executable.
%                      By default,/usr/local/cuda-8.0/bin
% LD_LIBRARY_PATH      Path to theCUDA libraries. 
%                      By default, /usr/local/cuda-8.0/lib64
% NVIDIA_CUDNN         Path to the root folder of cuDNN install
%% Create the Series network from pre trained caffe model

net = getYoloFromCaffe();
% It containes 56 layers. These are convolution layers followed by leaky
% ReLU , and fully connected layers in the end.

disp(net.Layers);


%% download example video
if ~exist('./downtown_short.mp4', 'file')
	url = 'https://www.mathworks.com/supportfiles/gpucoder/media/downtown_short.mp4';
	websave('downtown_short.mp4', url);
end

%% Generate code from series network

% Generate code for the host platform
cnncodegen(net, 'targetarch', 'host', 'opencv', 1, 'targetmain', ...
    'main.cpp', 'codetarget', 'rtw:exe');

% Note:
% In Linux , the above may fail in MATLAB due to open_cv library path conflicts
% If that happens, build the executable in your system terminal directly using commands
% below :
% make -f codegen/cnnbuild_rtw.mk

%%  Generated code description
% This generates the .cu and header files within the 'codegen'
% directory within the current folder. The files are compiled into an executable
% 'cnnbuild' ('cnnbuild.exe' in Windows) using main.cpp. The exe is emitted outside the codegen directory.
% The build includes opencv headers for compilation.



% The files conv_w and conv_b are the
% binary weights and bias file for convolution layer in the network
% The files fc_w and fc_b are the
% binary weights and bias file for fully connected layer in the network.

dir('codegen')

%% Main file 

% The main file creates and sets up the CnnMain network object with 
% layers and weights. It use the opencv VideoCapture method to 
% read frames from input video. It runs prediction for each frame
% fetching the output from the final fully connected layer.

% The class probabilities and bounding box values is read from the output 
% array and displayed. 

type('main.cpp');

%% Build and run executable

% run with example video file
if ispc
    system('cnnbuild.exe downtown_short.mp4');
else
    system('./cnnbuild downtown_short.mp4');
end
%% Clean up

% To clean up artifacts remove codegen folder and yolo.caffemodel file within 
% the current folder
