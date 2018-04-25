function [out1,out2] = getTsdr

 %Copyright 2017 The MathWorks, Inc.

% return trained series network object for detecting Traffic Signals

 % download trained Detection Network model from URL
 if exist('yolo_tsr.mat','file') == 0
	url = 'https://www.mathworks.com/supportfiles/gpucoder/cnn_models/traffic_sign_detection/yolo_tsr.mat';
	websave('yolo_tsr.mat',url);
 end
 net = load('yolo_tsr.mat');
 f = fields(net);
 f = f{1};
 out1 = net.(f); 
 
% return trained series network object for recognizing Traffic Signals

 % download trained Recognition Network model from UR
 if exist('RecognitionNet.mat','file') == 0
	url = 'https://www.mathworks.com/supportfiles/gpucoder/cnn_models/traffic_sign_detection/RecognitionNet.mat';
	websave('RecognitionNet.mat',url);
 end
 net = load('RecognitionNet.mat');
 f = fields(net);
 f = f{1};
 out2 = net.(f);
 
end

% LocalWords:  Traffic Sign Detecion and Recognition supportfiles gpucoder cnn