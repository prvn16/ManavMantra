function [xd,cxd,thr] = modwtdenoise1D(x,wav,lev,softHard,scal)
%MATLAB Code Generation Private Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

% Only support 'mln' at present
coder.internal.assert(strcmpi(scal,'mln'),'Wavelet:modwt:ScalingError');

if isvector(x)
    wt = modwt(x,wav,lev);
else
    wt = x;
end
validateattributes(wt,{'double'},{'2d','real'},mfilename);
% Check to see that the level for denoising does not exceed the level
% of the transform
coder.internal.assert(lev < size(wt,1), ...
    'Wavelet:modwt:InvalidDenoiseLevel');
loglenx = log(length(x));
% Determine the level dependent thresholds
p2 = 1;
thr = 0;
for kk = 1:lev
    % Calculate threshold value
    madest = sqrt(2)*median(abs(wt(kk,:)))/0.6745;
    p2 = p2*2;
    madest2dp2 = 2*madest*madest/p2;
    thr = sqrt(madest2dp2*loglenx);
    % Threshold MODWT coefficients
    wt(kk,:) = wthresh(wt(kk,:),softHard,thr);
end
% Invert the MODWT
xd = imodwt(wt,wav);
cxd = wt;