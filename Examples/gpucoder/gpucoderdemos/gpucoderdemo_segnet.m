%% Code Generation for Semantic Segmentation Network
% 
% This example demonstrates code generation for an image segmentation application 
% that uses deep learning. It uses the |codegen| command to generate a MEX 
% function that runs prediction on a DAG Network object
% for SegNet [1], a popular deep learning network for image segmentation.
%
%   Copyright 2016 - 2018 The MathWorks, Inc.
%% Prerequisites
% * CUDA(R) - enabled NVIDIA(R) GPU with compute capability 3.2 or higher.
% * NVIDIA CUDA toolkit and driver.
% * NVIDIA cuDNN library (v7 and above).
% * Neural Network Toolbox(TM) to use a DAG Network object.
% * Image Processing Toolbox(TM) for reading and displaying images.
% * Computer Vision System Toolbox(TM) for |labeloverlay| function used in
% this example.
% * Environment variables for the compilers and libraries. For information 
% on the supported versions of the compilers and libraries, see 
% <matlab:web(fullfile(docroot,'gpucoder/gs/install-prerequisites.html'))
% Third-party Products>. For setting up the environment variables, see 
% <matlab:web(fullfile(docroot,'gpucoder/gs/setting-up-the-toolchain.html'))
% Environment Variables>.
%% Verify the GPU Environment
% Use the <matlab:doc('coder.checkGpuInstall') coder.checkGpuInstall> function
% and verify that the compilers and libraries needed for running this example
% are set up correctly.
coder.checkGpuInstall('gpu','codegen','cudnn','quiet');
%% About the Segmentation Network
% SegNet [1] is a popular type of convolutional neural network (CNN) designed
% for semantic image segmentation. It is a deep encoder-decoder multi-class
% pixel-wise segmentation network trained on the CamVid [2] dataset and imported into
% MATLAB(R) for inference. The SegNet [1] is trained to segment pixels belonging
% to 11 classes which include Sky, Building, Pole, Road, Pavement, Tree,
% SignSymbol, Fence, Car, Pedestrian and Bicyclist.
%
% For information regarding training a semantic segmentation network in MATLAB using
% the CamVid [2] dataset see
% <matlab:web(fullfile(docroot,'vision/examples/semantic-segmentation-using-deep-learning.html')) Semantic Segmentation Using Deep Learning>.

%% Create a New Folder and Copy Relevant Files
% 
% The following code will create a folder in your current
% working folder (pwd). The new folder will contain only the files
% that are relevant for this example. If you do not want to affect the
% current folder (or if you cannot generate files in this folder),
% change your working folder.
gpucoderdemo_setup('gpucoderdemo_segnet');
%% About the 'segnet_predict' Function
% 
% The <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_segnet','segnet_predict.m')) segnet_predict.m>
% function takes an image input and runs prediction on the image using the
% deep learning network saved in SegNet.mat file.
% The function loads the network object from SegNet.mat into a persistent
% variable _mynet_ . On subsequent calls to the function, the persistent object is reused for
% prediction.  
%
type('segnet_predict.m')

%% Get the Pre-trained SegNet DAG Network Object
%
net = getSegNet();

%%
%
% The DAG network contains 91 layers including convolution, batch normalization, pooling, unpooling and the
% pixel classification output layers.
disp(net.Layers);

%% Run MEX Code-generation for 'segnet_predict' Function 
%
% Generate CUDA code from design file 
% <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_segnet','segnet_predict.m')) segnet_predict.m>
%
% Create a GPU Configuration object for MEX target setting target language to C++. 
% Run the |codegen| command specifying an input of size
% [360,480,3]. This corresponds to the input layer size of SegNet.
cfg = coder.gpuConfig('mex');
cfg.TargetLang = 'C++';
codegen -config cfg segnet_predict -args {ones(360,480,3,'uint8')} -report
%%
% A warning is thrown regarding non-coalesced access to inputdata variable.
% This is because |codegen| command generates column major code. This needs
% to be transposed to row-major format to call the underlying cuDNN
% library. To avoid this transpose, use the 
% <matlab:doc('cnncodegen') cnncodegen command>
% for standalone code generation. This generates row-major code without any
% transposes.

%% Run Generated MEX 
%
% Load and display an input image.
im = imread('image.png');
imshow(im);
%% 
% Call _segnet_predict_ on the input image.
predict_scores = segnet_predict_mex(im);
%% 
% The _predict_scores_ variable is a 3 dimensional matrix having 11 channels corresponding to the pixel-wise prediction scores for every class. Compute the channel with the maximum prediction score to get pixel-wise
% labels.
[~,argmax] = max(predict_scores,[],3);

%%
% Overlay the segmented labels over the input image and display the
% segmented region

classes = [
    "Sky"
    "Building"
    "Pole"
    "Road"
    "Pavement"
    "Tree"
    "SignSymbol"
    "Fence"
    "Car"
    "Pedestrian"
    "Bicyclist"
    ];

cmap = camvidColorMap();
SegmentedImage = labeloverlay(im,argmax,'ColorMap',cmap);
figure
imshow(SegmentedImage);
pixelLabelColorbar(cmap,classes);


%% Run Command: Cleanup
%
% Clear mex to clear the static network object loaded in memory. 
%% 
%
clear mex;
cleanup

displayEndOfDemoMessage(mfilename)

%% References
% [1] Badrinarayanan, Vijay, Alex Kendall, and Roberto Cipolla. "SegNet: A
% Deep Convolutional Encoder-Decoder Architecture for Image Segmentation."
% _arXiv preprint arXiv:1511.00561,_ 2015.
%
% [2] Brostow, Gabriel J., Julien Fauqueur, and Roberto Cipolla. "Semantic
% object classes in video: A high-definition ground truth database."
% _Pattern Recognition Letters_ Vol 30, Issue 2, 2009, pp 88-97.
