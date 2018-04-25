function [cfs,MJ,LJ] = removemodwtboundarycoeffs(cfs,VJ,N,J,L,scalingvar)
%Remove MODWT boundary coefficients
%   [cfs,MJ,LJ] = removemodwtboundarycoeffs(cfs,VJ,N,J,L,scalingvar)
%   cfs -- wavelet coefficients
%   VJ --  scaling coefficients if the level is scalingvar or -corr is true
%   N -- length adjusted for boundary
%   J -- level
%   L -- Filter length
%   scalingvar -- logical to indicate scaling variance is computed

for jj = 1:J
    LJ(jj) = (2^jj - 1) * (L - 1);
    M = min(LJ(jj), N);
    cfs(jj,1:M) = NaN;
    MJ(jj) = N-M;
end

if (scalingvar)
    cfs(J+1,:) = VJ;
    cfs(J+1,1:M) = NaN;
    MJ(J+1) = N-M;
end







