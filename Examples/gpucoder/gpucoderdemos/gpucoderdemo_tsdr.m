%% Traffic Sign Detection and Recognition
%
% This example demonstrates how to generate CUDA(R) MEX code for a
% traffic sign detection and recognition application, that uses deep learning.
% Traffic sign detection and recognition is an important application for driver
% assistance systems, aiding and providing information to the driver about road signs.
%
% <<block_diagram_tsdr.png>>
%
% In this example, traffic sign detection and recognition is performed in
% three steps - detection, Non-Maximal Suppression (NMS) and recognition.
% First, the example detects the traffic signs on a given input image using
% an object detection network that is variant of the You Only Look Once (YOLO) network.
% Then, overlapping detections are suppressed using the NMS algorithm.
% Finally, the recognition network is used for classifying the detected traffic signs.
%
% Copyright 2016 - 2017 The MathWorks, Inc. 
%% Prerequisites
% * CUDA(R) - enabled NVIDIA(R) GPU with compute capability 3.2 or higher.
% * NVIDIA CUDA toolkit and driver.
% * NVIDIA cuDNN library (v5 and above).
% * Environment variables for the compilers and libraries. For more
% information see
% <matlab:web(fullfile(docroot,'gpucoder/gs/setting-up-the-toolchain.html'))
% Environment Variables>.
% * Neural Network Toolbox(TM) to use a SeriesNetwork object.
% * Image Processing Toolbox(TM) for reading and displaying images.
% * Computer Vision System Toolbox(TM) for the video reader, viewer and
% Non-Maximal Suppression (NMS) used in the example.
%% Create a New Folder and Copy Relevant Files
% The following line of code creates a folder in your current working 
% folder (pwd), and copies all the relevant files into this folder. If you 
% do not want to perform this operation or if you cannot generate files in 
% this folder, change your current working folder.
gpucoderdemo_setup('gpucoderdemo_tsdr');
%% Verify the GPU Environment
% Use the <matlab:doc('coder.checkGpuInstall') coder.checkGpuInstall> function
% and verify that the compilers and libraries needed for running this example
% are set up correctly.
coder.checkGpuInstall('gpu','codegen','cudnn','quiet');
%% About the Detection and Recognition Networks
% The detection network is trained in the Darknet framework and imported into MATLAB for inference. 
% Because the size of the traffic sign is relatively small with respect to that of the image and the number training samples per class are less in the training data, all the traffic signs are considered as a single class for training the detection network. 
% 
% The detection network divides the input image into a 7 X 7 grid and each grid cell detects a traffic sign if the center of the  traffic sign falls within the grid cell.
% Each cell predicts two bounding boxes and confidence scores for these bounding boxes. Confidence scores tells us whether the box contains an object or not.  
% Each cell also predicts on probability for finding the traffic sign in the grid cell. The final score is product of the above two. We apply a threshold of 0.2 on this final score to select the detections.
% 
% The recognition network is also trained on the same images by using MATLAB. 
%
% The <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_tsdr','trainRecognitionnet.m')) trainRecognitionnet.m>
% script demonstrates the training of the recognition network.
%% Get the Pre-trained SeriesNetwork
%
% Download the detection and recognition networks.
getTsdr();
%%
%
% The detection network contains 58 layers including convolution, leaky ReLU, and
% fully connected layers.
load('yolo_tsr.mat');
disp(yolo.Layers);
%%
%
% The recognition network contains 14 layers including convolution, fully connected, and the
% classification output layers.
load('RecognitionNet.mat');
disp(convnet.Layers);
%% About the 'tsdr_predict' Function
%
% The <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_tsdr','tsdr_predict.m')) tsdr_predict.m>
% function takes an image input, detects the traffic signs in the image by using the
% detection network. It also suppresses the overlapping
% detections(NMS) using selectStrongestBbox and recognizes the traffic sign by using the
% recognition network. The function loads the
% network objects from yolo_tsr.mat into a persistent variable _detectionnet_ and
% RecognitionNet.mat into a persistent variable _recognitionnet_. On subsequent calls
% to the function, the persistent objects are reused for traffic sign detection
% and recognition.
%
type('tsdr_predict.m')
%% Generate CUDA MEX for 'tsdr_predict' Function
%
% Create a GPU configuration object for MEX target and set the target language to C++.
% To generate CUDA MEX, use the |codegen| command and specify the input to be of size [480,704,3].
% This corresponds to the input image size of tsdr_predict function.
cfg = coder.gpuConfig('mex');
cfg.TargetLang = 'C++';
codegen -config cfg tsdr_predict -args {ones(480,704,3,'uint8')} -report
%%
% A warning is thrown regarding dynamically sized  variable boxes.
% This is because the number of detected boxes on an input image varies from
% image to image and depends on the number of traffic signs detected in the image.
% For the purposes of this example, this warning can be ignored.
%% Run the Generated MEX
%
% Load an input image.
im = imread('stop.jpg');
imshow(im);
%%
% Call tsdr predict function on the input image.
im = imresize(im, [480,704]);
[bboxes,classes] = tsdr_predict_mex(im);
%%
% Map the class numbers to traffic sign names in the class dictionary.
classNames = {'addedLane','slow','dip','speedLimit25','speedLimit35','speedLimit40','speedLimit45',...
    'speedLimit50','speedLimit55','speedLimit65','speedLimitUrdbl','doNotPass','intersection',...
    'keepRight','laneEnds','merge','noLeftTurn','noRightTurn','stop','pedestrianCrossing',...
    'stopAhead','rampSpeedAdvisory20','rampSpeedAdvisory45','truckSpeedLimit55',...
    'rampSpeedAdvisory50','turnLeft','rampSpeedAdvisoryUrdbl','turnRight','rightLaneMustTurn',...
    'yield','yieldAhead','school','schoolSpeedLimit25','zoneAhead45','signalAhead'};

classRec = classNames(classes);

%%
% Display the detected traffic signs.
outputImage = insertShape(im,'Rectangle',bboxes,'LineWidth',3);

for i = 1:size(bboxes,1)
    outputImage = insertText(outputImage,[bboxes(i,1)+bboxes(i,3) bboxes(i,2)-20],classRec{i},'FontSize',20,'TextColor','red');
end

imshow(outputImage);
%% Traffic Sign Detection and Recognition on a Video
%
% The included demo file
% <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_tsdr','tsdr_testVideo.m')) tsdr_testVideo.m>
% grabs frames from the test video, invokes traffic sign detection and recognition and plots the results on each frame of the test video.
%%
%
%    % Input video
%    v = VideoReader('stop.avi');
%    fps = 0;
%
%
%     while hasFrame(v)
%        % Take a frame
%        picture = readFrame(v);
%        picture = imresize(picture,[920,1632]);
%        % Call MEX function for Traffic Sign Detection and Recognition
%        tic;
%        [bboxes,clases] = tsdr_predict_mex(picture);
%        newt = toc;
%
%        % fps
%        fps = .9*fps + .1*(1/newt);
%
%        % display
%
%         displayDetections(picture,bboxes,clases,fps);
%      end
%% Run Command: Cleanup
%
% Use clear mex to remove the static network objects loaded in memory. Remove files and return to the original folder.
%%
%
clear mex;
cleanup

displayEndOfDemoMessage(mfilename)










































