function net = denoisingNetwork(ModelName)
%denoisingNetwork Image denoising network
%
%   net = denoisingNetwork(ModelName) returns a pretrained image denoising
%         network specified by a ModelName. 
%
%   NOTE: This function requires the Neural Network Toolbox.
%
%   Class Support
%   -------------
%
%   ModelName is a string or character vector. net is a network object.
%
%   Notes
%   -----
%
%   1. Current option for ModelName is dncnn which returns a pre-trained
%      denoising network for grayscale images. For model details, check
%      Matlab documentation.
%
%   References:
%   -----------
%
%   [1] Kai Zhang, Wangmeng Zuo, Yunjin Chen, Deyu Meng and Lei Zhang,
%       "Beyond a Gaussian Denoiser: Residual Learning of Deep CNN for Image
%       Denoising", IEEE Transactions on Image Processing, Feb 2017
%
%   Example 
%   -------
%
%   net = denoisingNetwork('dncnn');
%   I = imread('cameraman.tif');
%
%   noisyI = imnoise(I, 'gaussian', 0, 0.01);
%   denoisedI = denoiseImage(noisyI, net);
%
%   figure
%   imshowpair(noisyI,denoisedI,'montage');
%
%   See also dnCNNLayers, denoiseImage, denoisingImageSource 


%   Copyright 2017 The MathWorks, Inc.

images.internal.requiresNeuralNetworkToolbox(mfilename);

narginchk(1,1);
validateModelName(ModelName);

validModelNames = {'dncnn'};
ModelName = validatestring(ModelName, validModelNames, mfilename, 'ModelName');

switch ModelName
    case ('dncnn')
        data = load('defaultDnCNN-B-Grayscale.mat');    
        net = data.net;
end
end

function validateModelName(ModelName)
supportedClasses = {'char','string'};
attributes = {'nonempty','scalartext'};
validateattributes(ModelName,supportedClasses,attributes,mfilename, 'ModelName');
end