function M = wcfs2mat(C,S)
%WCFS2MAT Wavelet coefficients to matrix.
%   M = WCFS2MAT(C,S) returns a matrix or 3-D arry which contains
%    the coefficients of wavelet decomposition.
%   WCFS2MAT is used by Progressive Coefficients Significance 
%   Methods functions. 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 05-Jul-2002.
%   Last Revision: 05-Apr-2008.
%   Copyright 1995-2008 The MathWorks, Inc.

level = size(S,1)-2;
sizes = kron(S(1,1:2),2.^(0:level)');
sZ = S(end,1:2);
if size(S,2)<3 , sZ(3) = 1; else sZ(3) = 3; end
M = zeros(sZ);
idxBegs = flipud([[1,1];sizes(1:end-1,:)+1]);
for k = 1:level
    j = level+2-k;
    idxB = idxBegs(k,:);
    idxE = idxB + S(j,1:2)- 1;
    [H,V,D] = detcoef2('all',C,S,k);   
    M(1:S(j,1),idxB(2):idxE(2),:) = H;
    M(idxB(1):idxE(1),1:S(j,2),:) = V;
    M(idxB(1):idxE(1),idxB(2):idxE(2),:) = D;
end
A = appcoef2(C,S,'haar',level);
M(1:S(1,1),1:S(1,2),:) = A;
