function [xden,denoisedcfs,origcfs,thr] = FDRDenoise(x,wname,level,q,noiseestimate)
% This function is for internal use only. It may change in a future
% release.
xdec = mdwtdec('c',x,level,wname);
C = xdec.cd;
d1 = C{1};
nj = length(C);
% Original Coefficients
origcfs = [xdec.cd {xdec.ca}];


if strcmpi(noiseestimate,'levelindependent')
    normfac = 1/(-sqrt(2)*erfcinv(2*0.75));
    sigma = normfac*median(abs(d1));
elseif strcmpi(noiseestimate,'leveldependent')
    sigma = [];
end

if isempty(q)
    q = 0.05;
end

[cden,thr] = wavelet.internal.fdrthreshcfs(C,nj,q,sigma);
xdec.cd = cden;
% Denoised Coefficients
denoisedcfs = [xdec.cd {xdec.ca}];
xden = mdwtrec(xdec);

    
    
    
    
