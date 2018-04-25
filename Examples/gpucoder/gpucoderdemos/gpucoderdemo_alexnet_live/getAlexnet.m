function out = getAlexnet

% return trained series network object for AlexNet

 % download trained AlexNet model from URL
 if exist('alexnet.mat','file') == 0
	url = 'https://www.mathworks.com/supportfiles/gpucoder/cnn_models/alexnet/alexnet.mat';
	websave('alexnet.mat',url);
 end
 net = load('alexnet.mat');
 f = fields(net);
 f = f{1};
 out = net.(f); 
end

% LocalWords:  alexnet supportfiles gpucoder cnn
