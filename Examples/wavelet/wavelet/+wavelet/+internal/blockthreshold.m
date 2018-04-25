function [xden,denoisedcfs,origcfs] = blockthreshold(x,wname,level,lambda,L)
% This function is for internal use only. It may change in a future
% release. The function implements the block James-Stein estimator
% described in Cai (1999).
%
%
%   References
%   Cai, T.T. (1999). Adaptive wavelet estimation: a block
%   thresholding and oracle inequality approach. Ann. Statist.,
%   27, 898-924.

% This should never be a row vector but just in case
if isrow(x)
    x = x(:);
end

Norig = size(x,1);

% Default denoising level for block thresholding


xdec = mdwtdec('c',x,level,wname);
numdetcoefs = cell2mat(cellfun(@(x)size(x,1),xdec.cd,'uni',0));
% For block threshold we need at least L coefficients at the coarsest
% resolution where L = floor(log(N))
if min(numdetcoefs) < L
    CoarsestLevel = find(numdetcoefs>=L,1,'last');
    error(message('Wavelet:FunctionInput:InvalidBlockLevel',num2str(CoarsestLevel)));
end
d1 = xdec.cd{1};
% Original Coefficients
origcfs = [xdec.cd {xdec.ca}];
wthrcoef = cell(size(xdec.cd));



% Estimate noise variance based on finest-scale wavelet coefficients
% The normalization factor is equivalent to the inverse N(0,1) CDF
% evaluated at 0.75.
normfac = 1/(-sqrt(2)*erfcinv(2*0.75));
sigma = normfac*median(abs(d1));
% Initialize the thresholded wavelet coefficients to the original


for lev = level:-1:1
    wthrcoef{lev} = wavelet.internal.blockJS(xdec.cd{lev},lambda,L,sigma);
end



% Better to use filters here
xdec.cd = wthrcoef;
% Denoised Coefficients
denoisedcfs = [xdec.cd {xdec.ca}];
xden = mdwtrec(xdec);
xden = xden(1:Norig,:);










