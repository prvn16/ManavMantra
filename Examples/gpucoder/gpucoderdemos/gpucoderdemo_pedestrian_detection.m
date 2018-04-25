%% Pedestrian Detection
%  
% This example demonstrates code generation for pedestrian detection
% application that uses deep learning. Pedestrian detection is a key 
% problem in computer vision, with several applications in the fields of 
% autonomous driving, surveillance, robotics etc.
%
%   Copyright 2017 The MathWorks, Inc.
%% Prerequisites
% * CUDA(R) - enabled NVIDIA(R) GPU with compute capability 3.2 or higher.
% * NVIDIA CUDA toolkit and driver.
% * NVIDIA cuDNN library (v5 and above).
% * Computer Vision System Toolbox(TM).
% * Neural Network Toolbox(TM) to use a SeriesNetwork object.
% * Image Processing Toolbox(TM) for reading and displaying images.
% * Environment variables for the compilers and libraries. For more 
% information, see 
% <matlab:web(fullfile(docroot,'gpucoder/gs/setting-up-the-toolchain.html'))
% Environment Variables>.
%
%% Create a New Folder and Copy Relevant Files
% 
% The following code will create a folder in your current
% working folder (pwd). The new folder will contain only the files 
% that are relevant for this example. If you do not want to affect the
% current folder (or if you cannot generate files in this folder),
% change your working folder.
gpucoderdemo_setup('gpucoderdemo_pedestrian_detection');

%% Verify the GPU Environment
% Use the <matlab:doc('coder.checkGpuInstall') coder.checkGpuInstall> function
% and verify that the compilers and libraries needed for running this example
% are set up correctly.
coder.checkGpuInstall('gpu','codegen','cudnn','quiet');

%% About the Network
% The pedestrian detection network was trained by using images of 
% pedestrians and non-pedestrians. This network is trained in MATLAB by using 
% the <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_pedestrian_detection','trainPedNet.m'))
% trainPedNet.m> script. A sliding window approach is used to crop patches from an
% image of size [64 32] as shown. Patch dimensions are obtained from heat map which  
% represents the distribution of pedestrians in the images in the data set. 
% It indicates the presence of pedestrians at various scales and locations in the images.  
% In this demo, patches of pedestrians close to camera are cropped and processed.
% Finally, Non-Maximal Suppression (NMS) is applied on the obtained 
% patches to merge them together and detect complete pedestrians.
%
% <<PedNetworkBlock.png>> 
%%
%
% The pedestrian detection network contains 12 layers which include 
% convolution, fully connected, and classification output layers.
load('PedNet.mat');
disp(PedNet.Layers);

%% About the 'pedDetect_predict' Function
% 
% The <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_pedestrian_detection','pedDetect_predict.m')) pedDetect_predict.m>
% function takes an image input and runs prediction on image using the
% deep learning network saved in PedNet.mat file.
% The function loads the network object from PedNet.mat into a persistent
% variable _pednet_. On subsequent calls to the function, the persistent
% object is reused for prediction.  
%
type('pedDetect_predict.m')

%% Generate CUDA MEX for the pedDetect_predict Function
%
%
% Create a GPU Configuration object for MEX target and set the target 
% language to C++. To generate CUDA MEX, use the |codegen| command and 
% specify the size of the input image size. This corresponds to the input 
% layer size of pedestrian detection network.

% Load an input image.
im = imread('test.jpg');
im = imresize(im,[480,640]);

cfg = coder.gpuConfig('mex');
cfg.TargetLang = 'C++';
codegen -config cfg pedDetect_predict -args {im} -report

%%
% A warning is thrown regarding dynamically sized variable weights.
% This is because the number of detected boxes on an input image varies from 
% image to image and depends on the number of pedestrians in the image.
% For the purposes of this example, this warning can be ignored. 

%% Run the Generated MEX 
%
imshow(im);

%% 
% Call pednet predict on the input image.
ped_bboxes = pedDetect_predict_mex(im);

%%
% Display final predictions.
outputImage = insertShape(im,'Rectangle',ped_bboxes,'LineWidth',3);
imshow(outputImage);

%% Classification on a Video
%
% The included demo file 
% <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_pedestrian_detection','pedDetect_predict.m')) pedDetect_predict.m>
% grabs frames from a video, invokes prediction, and displays the classification results on each of the captured video frames.
%%
%    v = VideoReader('LiveData.avi');
%    fps = 0;
%    while hasFrame(v)
%       % Read frames from video
%       im = readFrame(v);      
%       im = imresize(im,[480,640]);
%    
%       % Call MEX function for pednet prediction
%       tic;    
%       ped_bboxes = pedDetect_predict_mex(im);
%       newt = toc;
%       
%       % fps 
%       fps = .9*fps + .1*(1/newt);
%    
%       % display
%       outputImage = insertShape(im,'Rectangle',ped_bboxes,'LineWidth',3);
%       imshow(outputImage)
%       pause(0.2)
%    end
%% Run Command: Cleanup
%
% Use clear mex to remove the static network object loaded in memory. 
% Remove files and return to the original folder.
%% 
%
clear mex;
cleanup

displayEndOfDemoMessage(mfilename)
