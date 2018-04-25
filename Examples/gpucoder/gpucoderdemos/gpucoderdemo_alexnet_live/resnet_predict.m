% Copyright 2018 The MathWorks, Inc.

function out = resnet_predict(in) 
%#codegen

% A persistent object mynet is used to load the series network object.
% At the first call to this function, the persistent object is constructed and
% setup. When the function is called subsequent times, the same object is reused 
% to call predict on inputs, thus avoiding reconstructing and reloading the
% network object.

persistent mynet;

if isempty(mynet)
    % Pass in name of the function 'resnet50' that returns a DAG network
    % for ResNet-50 model.
    mynet = coder.loadDeepLearningNetwork('resnet50','resnet');
end

% pass in input   
out = mynet.predict(in);
