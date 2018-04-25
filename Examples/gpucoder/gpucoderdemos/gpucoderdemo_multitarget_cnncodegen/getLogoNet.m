function out = getLogoNet()
% Copyright 2017 The MathWorks, Inc.

% return trained series network object for logonet

 % download trained Logonet model from URL
 if exist('LogoNet.mat','file') == 0
	url = 'https://www.mathworks.com/supportfiles/gpucoder/cnn_models/logo_detection/LogoNet.mat';
	websave('LogoNet.mat',url);
 end
 net = load('LogoNet.mat');
 f = fields(net);
 f = f{1};
 out = net.(f); 
end