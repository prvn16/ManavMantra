function out = logonet_predict(in)
%#codegen

% Copyright 2017 The MathWorks, Inc.

% function for predicting the logos
% A persistent object logonet is used to load the series network object.
% At the first call to this function, the persistent object is constructed and
% setup. When the function is called subsequent times, the same object is reused 
% to call predict on inputs, thus avoiding reconstructing and reloading the
% network object.

persistent logonet;

if isempty(logonet)
    
    logonet = coder.loadDeepLearningNetwork('LogoNet.mat','logonet');
end

out = logonet.predict(in);

end