function out = getYolo

%   Copyright 2017 The MathWorks, Inc.

% return a trained series network object for Yolo network
 if exist('yolonet.mat','file') == 0
	url = 'https://www.mathworks.com/supportfiles/gpucoder/cnn_models/Yolo/yolonet.mat';
	websave('yolonet.mat',url);
 end
 nnet = load('yolonet.mat');
 out = nnet.yolonet; 

end
