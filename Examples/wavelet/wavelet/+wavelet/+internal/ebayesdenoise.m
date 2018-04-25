function [xden,denoisedcfs,origcfs] = ebayesdenoise(x,wname,level,noiseestimate,threshold)
% This function is for internal use only. It may change in a future
% release.
xdec = mdwtdec('c',x,level,wname);
wthr = xdec.cd;
d1 = wthr{1};
% Original Coefficients
origcfs = [xdec.cd {xdec.ca}];


if strcmpi(noiseestimate,'levelindependent')
    normfac = 1/(-sqrt(2)*erfcinv(2*0.75));
    vscale = normfac*median(abs(d1));
elseif strcmpi(noiseestimate,'leveldependent')
    vscale = noiseestimate;
end

for lev = 1:level
    wthr{lev} = wavelet.internal.ebayesthresh(wthr{lev},vscale,threshold,'decimated');
end
xdec.cd = wthr;
% Denoised Coefficients
denoisedcfs = [xdec.cd {xdec.ca}];
xden = mdwtrec(xdec);








