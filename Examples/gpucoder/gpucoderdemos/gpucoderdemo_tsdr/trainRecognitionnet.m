%   This script demonstrates training for traffic sign recognition network.
%
%   Copyright 2017 The MathWorks, Inc.

% Location of the training data set folder that has training images of
% cropped traffic signs in separate folders.
trainigDataPath = '';
tsrDatasetPath = fullfile(trainigDataPath);

tsrData = imageDatastore(tsrDatasetPath,...
    'IncludeSubfolders',true,'LabelSource','foldernames');


minSetCount = min(tsrData.countEachLabel{:,2});
trainingNumFiles = round(minSetCount * 1);
[trainTsrData,testTsrData] = splitEachLabel(tsrData, ...
    trainingNumFiles,'randomize');
numClasses = 35; % Number of classes(traffic signs) in the training data
% Training options and Network Architecture
layers= [imageInputLayer([48 48 3],'DataAugmentation','randfliplr','normalization','zerocenter' )
    convolution2dLayer(7,100,'Stride',1)
    reluLayer()
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(4,150,'Stride',1)
    reluLayer()
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(4,250,'Stride',1)
    maxPooling2dLayer(2,'Stride',2)
    fullyConnectedLayer(300)
    dropoutLayer(0.8)
    fullyConnectedLayer(numClasses)
    softmaxLayer()
    classificationLayer()];

options = trainingOptions('sgdm','MaxEpochs',150, ...
    'InitialLearnRate',0.001,'MiniBatchSize',128);


convnet = trainNetwork(trainTsrData,layers,options);


% Save the Trained Network in matfile
save('RecognitionNet.mat','convnet');
