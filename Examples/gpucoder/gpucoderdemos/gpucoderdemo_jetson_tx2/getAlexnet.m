function out = getAlexnet

%  Copyright 2017 The MathWorks, Inc.

% return trained series network object for Alexnet

 % download trained AlexNet model from URL
 if exist('alexnet.mat','file') == 0
	url = 'https://www.mathworks.com/supportfiles/gpucoder/cnn_models/alexnet/alexnet.mat';
	websave('alexnet.mat',url);
 end
 net = load('alexnet.mat');
 fieldnames = fields(net);
 out = net.(fieldnames{1});
end

% LocalWords:  Alexnet
