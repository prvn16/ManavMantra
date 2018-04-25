% Copyright 2018 The MathWorks, Inc.

function out = googlenet_predict(in) 
%#codegen

% A persistent object mynet is used to load the series network object.
% At the first call to this function, the persistent object is constructed and
% setup. When the function is called subsequent times, the same object is reused 
% to call predict on inputs, thus avoiding reconstructing and reloading the
% network object.

persistent mynet;

if isempty(mynet)
    % Pass in name of the function 'resnet50' that returns a DAG network
    % for GoogLeNet model.
    mynet = coder.loadDeepLearningNetwork('googlenet','googlenet');
end

% pass in input   
out = mynet.predict(in);
