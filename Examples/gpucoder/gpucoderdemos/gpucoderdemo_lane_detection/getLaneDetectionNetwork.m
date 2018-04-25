function [trainedNet, mean, stds] = getLaneDetectionNetwork

% return a trained series network object for Lane detection network
% Also returns the mean and stds for the outputs of training data

if exist('trainedLaneNet.mat','file') == 0
	url = 'https://www.mathworks.com/supportfiles/gpucoder/cnn_models/lane_detection/trainedLaneNet.mat';
	websave('trainedLaneNet.mat',url);
    load('trainedLaneNet.mat');
    save('laneNet.mat', 'laneNet'); 
end
nnet = load('trainedLaneNet.mat');
trainedNet = nnet.laneNet;
mean = nnet.laneCoeffMeans;
stds = nnet.laneCoeffsStds;

end