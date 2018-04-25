function out = alexnet_test(in, matfile)

%#codegen
persistent mynet;

if isempty(mynet)   
    mynet = coder.loadDeepLearningNetwork(coder.const(matfile),'alexnet');
end

out = mynet.predict(in);
