function outputImage = remapmex(inputImage, X, Y, method, fillValues) %#codegen
%Copyright 2013-2015 The MathWorks, Inc.

coder.inline('always');
coder.internal.prefer_const(inputImage, X, Y, method, fillValues);

eml_invariant(eml_is_const(method),...
    eml_message('images:remapmex:methodStringNotConst'),...
    'IfNotConst','Fail');

validatestring(method, {'nearest', 'bilinear', 'bicubic'}, 'remapmex', 'InterpolationMethod'); %#ok<*EMCA>

outputImageSize = size(inputImage);
outputImageSize(1) = size(X,1);
outputImageSize(2) = size(X,2);

outputImage = coder.nullcopy(zeros((outputImageSize), 'like', inputImage));

% number of threads (obtained at compile time)
singleThread = images.internal.coder.useSingleThread();

methodEnum = 1;
if (strcmp(method, 'nearest'))
    methodEnum = 1;
elseif (strcmp(method, 'bilinear'))
    methodEnum = 2;
elseif (strcmp(method, 'bicubic'))
    methodEnum = 3;
end

if singleThread
    fcnName = ['remap_', images.internal.coder.getCtype(inputImage)];
    outputImage = images.internal.coder.buildable.remapBuildable.remapCore(fcnName, ...
        inputImage,  ...
        Y, ...
        X, ...
        int8(methodEnum), ...
        fillValues, ...
        outputImage);
else
    fcnName = ['remaptbb_', images.internal.coder.getCtype(inputImage)];
    outputImage = images.internal.coder.buildable.remaptbbBuildable.remapCore(fcnName, ...
        inputImage,  ...
        Y, ...
        X, ...
        int8(methodEnum), ...
        fillValues, ...
        outputImage);
end
