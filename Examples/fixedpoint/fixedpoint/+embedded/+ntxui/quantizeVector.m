function [qval,valSat] = quantizeVector(val,signed,wl,fl,rnd)
%Quantize a vector of values in floating point.
%  quantizeVector(V,S,WL,FL,Round) quantize the vector of values V using
%  signed format S (signed if true, unsigned otherwise), word length WL,
%  fraction length FL, and round mode Round which is an integer,
%     1=ceil, 2=convergent, 3=floor, 4=nearest, 5=round, 6=zero/fix.
%
%  [qval,qsat]=quantizeVector(...) returns a logical vector qsat indicating
%  values that were saturated during quantization.
%
%  Only saturation is supported, not wrap.

%   Copyright 2010 The MathWorks, Inc.

% Create the quantizer object only once for performance.
persistent qz;

rndMode = {'ceil','convergent','floor','nearest','round','zero'};
dataMode = {'ufixed','fixed'};
qMode = dataMode{int8(signed)+1};

qval = quantizenumeric(val,signed,wl,fl,rndMode{rnd},'Saturate');

if isempty(qz)
    qz = quantizer(qMode,rndMode{rnd},'Saturate',[wl fl]);
end
set(qz,'DataMode',qMode);
set(qz,'RoundMode',rndMode{rnd});
set(qz,'Format',[wl fl]);

% Find the index of data that was saturated.
satUpper = val > qz.upperbound;
satLower = val < qz.lowerbound;
valSat = satUpper|satLower;
