function [I, minI, maxI] = imlinscale(I,outputRange,inputRange)
% Function to linearly scale input data to a target range. Note: Because
% of the normalization involved, output I is always of class single unless
% input image is of class double in which case the output is also of class
% double.

% Copyright 2014 The MathWorks, Inc.

if nargin < 2
    outputRange = [0 1];
end
if isempty(outputRange)
    outputRange = [0 1];
end
if nargin < 3
    inputRange = [];
end

if isinteger(I)
    I = single(I);
end

if ~isempty(inputRange)
    minI = inputRange(1);
    maxI = inputRange(2);
    I(I < minI) = minI;
    I(I > maxI) = maxI;
else
    minI = min(I(:));
    maxI = max(I(:));
end

if (maxI - minI) > eps(maxI)    
    I = outputRange(1) + (outputRange(2) - outputRange(1))/ ...
        (maxI - minI)*(I - minI);
else
    warning(message('images:validate:zeroDataSpread'));    
end