% This is a sample script that demonstrates the data augmentation used to
% increase the number of training samples during the logonet training on a
% single image and also training of the logonet.
%
% Copyright 2017 The MathWorks, Inc.

%% Data Augmentation
% Four types of data augmentation are used during logonet training. They are :
% Contrast normalization, gaussian blur, random flipping and shearing. In
% this section a sample image(peppers.png) is used as example to show
% the data augmentation.


I = imread('peppers.png');

%% random flip
a = 0;
b = 360;
angle = (b-a).*rand(1,1) + a;
iRF = imrotate(I,angle);
iRF = imresize(iRF,[227 227]);

%% blur
iBlur = imgaussfilt(I, 2);

%% shearing
aa = 0;
bb = 1;
shearangle = (bb-aa).*rand(1,1) + aa;
T = maketform('affine', [1 0 0; shearangle 1 0; 0 0 1] );
R = makeresampler({'cubic','nearest'},'fill');
iShear = imtransform(I,T,R);

%% contrast normalization
Idouble = double(I);
Imean = mean(mean(Idouble));
Icn = zeros(size(I));
for i = 1: size(I,3)
    Icn(:,:,i) = (Idouble(:,:,i)-Imean(i))./(std2(Idouble(:,:,i)));
end

%% Logonet training


trainigDataPath = ''; % Location of the training data set folder that has training images of logos in separate folders
logoDatasetPath = fullfile(trainigDataPath);

logoData = imageDatastore(logoDatasetPath,...
    'IncludeSubfolders',true,'LabelSource','foldernames');


minSetCount = min(logoData.countEachLabel{:,2});
trainingNumFiles = round(minSetCount * 1);


[trainLogoData,testLogoData] = splitEachLabel(logoData, ...
    trainingNumFiles,'randomize');
numClasses = 32; % Number of classes(logos) in the training data
% layers
inputLayer=imageInputLayer([227 227 3],'DataAugmentation','randfliplr','normalization', ...
    'zerocenter');
c1=convolution2dLayer(5,96,'Stride',1,'NumChannels',3,'WeightLearnRateFactor',1, ...
    'BiasLearnRateFactor',2,'WeightL2Factor',1,'BiasL2Factor',0);
c1.Weights = randn([5 5 3 96])*0.0001;
c1.Bias = randn([1 1 96])*0.00001+1;
r1 =  reluLayer();
p1= maxPooling2dLayer(3,'Stride',2);
c2=convolution2dLayer(3,128,'Stride',1,'NumChannels',96,'WeightLearnRateFactor',1, ...
    'BiasLearnRateFactor',2,'WeightL2Factor',1,'BiasL2Factor',0);
r2 =  reluLayer();
p2=maxPooling2dLayer(3,'Stride',2);
c3=convolution2dLayer(3,384,'Stride',1,'NumChannels',128,'WeightLearnRateFactor',1, ...
    'BiasLearnRateFactor',2,'WeightL2Factor',1,'BiasL2Factor',0);
r3 =  reluLayer();
p3=maxPooling2dLayer(3,'Stride',2);
c5=convolution2dLayer(3,128,'Stride',2,'NumChannels',384,'WeightLearnRateFactor',1, ...
    'BiasLearnRateFactor',2,'WeightL2Factor',1,'BiasL2Factor',0);
r5 =  reluLayer();
p5=maxPooling2dLayer(3,'Stride',2);
f7 = fullyConnectedLayer(2048);
r7 = reluLayer();
d7 = dropoutLayer(0.5);
f8=fullyConnectedLayer(numClasses);
s8=softmaxLayer;
outputLayer=classificationLayer;

layers = [inputLayer; c1; r1; p1; c2; r2; p2; c3; r3; p3;...
    c5; r5; p5; f6; r6; d6; f7;r7; d7; f8; s8; outputLayer];

options = trainingOptions('sgdm', ...
    'MaxEpochs',40, ...
    'InitialLearnRate',0.0001,...
    'Verbose',true,'MiniBatchSize',45);

rng(2016) % For reproducibility

convnet = trainNetwork(trainLogoData,layers,options);

% Save the Trained Network in matfile
save('LogoNet.mat','convnet');







