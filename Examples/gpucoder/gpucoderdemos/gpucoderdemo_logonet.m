%% Logo Recognition Network
%  
% This example demonstrates code generation for a logo classification application 
% that uses deep learning. It uses the |codegen| command to generate a MEX 
% function that runs prediction on a SeriesNetwork object
% called LogoNet.
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
%% Create a New Folder and Copy Relevant Files
% The following line of code creates a folder in your current working 
% folder (pwd), and copies all the relevant files into this folder. If you 
% do not want to perform this operation or if you cannot generate files in 
% this folder, change your current working folder.
gpucoderdemo_setup('gpucoderdemo_logonet');
%% Verify the GPU Environment
% Use the <matlab:doc('coder.checkGpuInstall') coder.checkGpuInstall> function
% and verify that the compilers and libraries needed for running this example
% are set up correctly.
coder.checkGpuInstall('gpu','codegen','cudnn','quiet');
%% About the Network
% Logos can  be used to provide useful information to assist users. Logos 
% find their applications under various domains like advertising, document
% community, etc. 
% This network was developed in MATLAB and it can     
% recognize 32 logos under various lightning conditions and camera motions.
% The architecture of this network is similar to AlexNet.
% Since this network focuses only on recognition it can be used in      
% applications where localization is not required. 
%
%% Training the Network
% Network is trained in MATLAB and the training data used for logo 
% classification contains around 200 images for each logo.
% Since the number of images used for training the network is small,
% data augmentation is used to increase the number of training samples.
% Four types of data augmentation are used: 
% Contrast normalization, gaussian blur, random flipping, and shearing. This
% data augmentation helps in recognizing logos in images captured at
% different lighting conditions and camera motions.
% Input size for logonet is [227 227 3]. Standard SGDM is used for training 
% with a learning rate of 0.0001 for 40 epochs with a mini batch size of 45.
% The <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_logonet','trainLogonet.m')) trainLogonet.m>
% script demonstrates the data augmentation on an a sample image,
% architecture of the logonet and training options used for training.
%
%% Get the Pre-trained SeriesNetwork
%
% Download logonet network and save to LogoNet.mat if it does not already exist.
getLogonet();
%%
%
% The saved network contains 22 layers including convolution, fully connected, and the
% classification output layers.
load('LogoNet.mat');
disp(convnet.Layers);
%% About the 'logonet_predict' Function
% 
% The <matlab:edit(fullfile(matlabroot,'toolbox','gpucoder','gpucoderdemos','gpucoderdemo_logonet','logonet_predict.m')) logonet_predict.m>
% function takes an image input and runs prediction on the image using the
% deep learning network saved in LogoNet.mat file.
% The function loads the network object from LogoNet.mat into a persistent
% variable _logonet_ . On subsequent calls to the function, the persistent object is reused for
% prediction.  
%
type('logonet_predict.m')
%% Generate CUDA MEX for 'logonet_predict' Function 
%
% Create a GPU configuration object for MEX target and set the target language
% to C++. To generate CUDA MEX, use the |codegen| command and specify the input 
% to be of size [227,227,3]. 
% This corresponds to the input layer size of the logonet network.
cfg = coder.gpuConfig('mex');
cfg.TargetLang = 'C++';
codegen -config cfg logonet_predict -args {ones(227,227,3,'uint8')} -report
%%
% The warning about non-coalesced access is because |codegen| command generates 
% column major code. However, for the purposes of this example, this warning 
% can be ignored.
%% Run the Generated MEX 
%
% Load an input image.
im = imread('test.png');
imshow(im);
%% 
% Call logonet predict on the input image.
im = imresize(im, [227,227]);
predict_scores = logonet_predict_mex(im);
%% 
% Map the top five prediction scores to words in the synset dictionary (logos).
synsetOut = {'adidas', 'aldi', 'apple', 'becks', 'bmw', 'carlsberg', ...
    'chimay', 'cocacola', 'corona', 'dhl', 'erdinger', 'esso', 'fedex',...
    'ferrari', 'ford', 'fosters', 'google', 'guinness', 'heineken', 'hp',...
    'milka', 'nvidia', 'paulaner', 'pepsi', 'rittersport', 'shell', 'singha', 'starbucks', 'stellaartois', 'texaco', 'tsingtao', 'ups'};

[val,indx] = sort(predict_scores, 'descend');
scores = val(1:5)*100;
top5labels = synsetOut(indx(1:5)); 
%%
% Display the top 5 classification labels.
outputImage = zeros(227,400,3, 'uint8');
for k = 1:3
    outputImage(:,174:end,k) = im(:,:,k);
end

scol = 1;
srow = 20;

for k = 1:5
    outputImage = insertText(outputImage, [scol, srow], [top5labels{k},' ',num2str(scores(k), '%2.2f'),'%'], 'TextColor', 'w','FontSize',15, 'BoxColor', 'black');
    srow = srow + 20;
end

 imshow(outputImage);
%% Run Command: Cleanup
%
% Use clear mex to remove the static network object loaded in memory. Remove files and return to the original folder.
%% 
%
clear mex;
cleanup

displayEndOfDemoMessage(mfilename)
