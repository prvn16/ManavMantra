function NSSfeatures = computeNSSFeatures(im)
% computeNSSFeatures computes the Natural Scene Statistics (NSS) based
%   features for an image. They are used to calculate no-reference image
%   quality metrics such as NIQE and BRISQUE.

% Copyright 2016 The MathWorks, Inc.

NSSfeatures = zeros(18,1);
[alpha, betal, betar] = images.internal.estimateAGGDParameters(im(:));
NSSfeatures(1) = alpha;
NSSfeatures(2) = (betal+betar)/2;

pair_shifts = [0 1; 1 0;1 1; 1 -1];
idx = 3;
for i = 1:4
    im_shifted = circshift(im,pair_shifts(i,:));
    mult = im .* im_shifted;
    [alpha, betal, betar] = images.internal.estimateAGGDParameters(mult(:));
    distmean = (betar-betal)*(gamma(2/alpha)/gamma(1/alpha));
    NSSfeatures(idx) = alpha;
    NSSfeatures(idx+1) = distmean;
    NSSfeatures(idx+2) = betal;
    NSSfeatures(idx+3) = betar;
    idx = idx + 4;
end