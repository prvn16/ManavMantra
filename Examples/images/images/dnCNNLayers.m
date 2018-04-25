function layers = dnCNNLayers(varargin)
%dnCNNLayers    Get DnCNN (Denoising CNN) network layers
%
%   layers = dnCNNLayers() returns layers of the DnCnn network for grayscale images.
%
%   layers = dnCNNLayers(___, Name, Value) returns layers of the DnCnn network
%            for grayscale images with additional parameters specifying
%            network architecture.
%   
%   Parameters are:
%
%   NetworkDepth    : Integer specifying the depth of the network in terms
%                     of the number of convolution layers. Minimum depth is 3. 
%                     Default is 20.
%
%   NOTE: This function requires the Neural Network Toolbox.
%
%   Notes
%   -----
%
%   1. Refer to Matlab documentation for specifics of the DnCnn network
%      architecture.
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
%   imds = imageDatastore(pathToGrayscaleNaturalImageData);
%  
%   source = denoisingImageSource(imds,...
%       'PatchesPerImage', 512,...
%       'PatchSize', 50,...
%       'GaussianNoiseLevel', [0.01 0.1], ...
%       'ChannelFormat', 'grayscale');
%  
%   layers = dnCNNLayers();
%  
%   opts = trainingOptions('sgdm');
%  
%   net = trainNetwork(source,layers,opts);
%
%   See also denoisingImageSource, denoiseImage, denoisingNetwork 


%   Copyright 2017 The MathWorks, Inc.


images.internal.requiresNeuralNetworkToolbox(mfilename);

narginchk(0,2);
options = parseInputs(varargin{:});
NetworkDepth = options.NetworkDepth;

layers = getDnCNNLayers('grayscale', NetworkDepth);
end

function options = parseInputs(varargin)
parser = inputParser();
parser.addParameter('NetworkDepth',20,@validateNetworkDepth);
parser.parse(varargin{:});
options = parser.Results;
end

function validateNetworkDepth(NetworkDepth)
supportedClasses = images.internal.iptnumerictypes;
attributes = {'nonempty','nonsparse','real','nonnan','finite', 'integer', ...
    '>=',3,'positive','nonzero','scalar'};
validateattributes(NetworkDepth,supportedClasses,attributes,mfilename, ...
    'NetworkDepth');
end

function layers = getDnCNNLayers(ChannelFormat, NetworkDepth)

if strcmp(ChannelFormat,'grayscale')
    c = 1;
else
    c = 3;
end
layers = imageInputLayer([50 50 c],'Name','InputLayer','Normalization','none');
convLayer = convolution2dLayer(3,64,...
    'Padding', 1, ...
    'BiasL2Factor', 0,...
    'Name', 'Conv1');
% He initialization
convLayer.Weights = sqrt(2/(9*64))*randn(3,3,c,64);
convLayer.Bias = zeros(1,1,64);

relLayer = reluLayer('Name', 'ReLU1');
layers = [layers convLayer relLayer];

for layerNumber = 2:NetworkDepth-1
    convLayer = convolution2dLayer(3, 64,...
        'BiasLearnRateFactor',0,...
        'BiasL2Factor', 0,...
        'Padding', [1 1],...
        'Name', ['Conv' num2str(layerNumber)]);
    % He initialization
    convLayer.Weights = sqrt(2/(9*64))*randn(3,3,64,64);
    convLayer.Bias = zeros(1,1,64);

    scaleInit = sqrt(2/(9*64))*randn(1,1,64);
    batchNormLayer = batchNormalizationLayer('Offset',zeros(1,1,64),...
        'Scale', scaleInit,...
        'OffsetL2Factor',0,...
        'ScaleL2Factor',0,...
        'Name',['BNorm' num2str(layerNumber)]);

    relLayer = reluLayer('Name', ['ReLU' num2str(layerNumber)]);
    layers = [layers convLayer batchNormLayer relLayer];     %#ok<AGROW>
end

convLayer = convolution2dLayer(3,c,...
    'NumChannels',64,...
    'Padding', [1 1],...
    'BiasL2Factor', 0,...
    'Name', ['Conv' num2str(NetworkDepth)]);
convLayer.Weights = sqrt(2/(9*64))*randn(3,3,64,c);
convLayer.Bias = zeros(1,1,c);

layers = [layers convLayer];
layers = [layers regressionLayer('Name','FinalRegressionLayer')];

end
