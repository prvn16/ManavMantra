function [C,sizeCFS] = wmat2cfs(M,level,SizeINI)
%WMAT2CFS 
%   [C,SIZECFS] = WMAT2CFS(M,LEVEL,SIZEINI)
%

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 05-Jul-2002.
%   Last Revision 25-May-2004.

if nargin<3 , SizeINI = size(M,1:2); end
[sizeCFS,sizesUTL] = getsizes(level,SizeINI);
idxBegs = flipud([[1,1];sizesUTL(1:end-1,:)+1]);
lev2 = level+2;
if length(size(M))<3
    mul = 1; 
else
    mul = 3; sizeCFS(:,3) = 3;
end

tmp = prod(sizeCFS(:,1:2),2);
nbCFS = mul*(3*sum(tmp(2:end-1))+tmp(1));
C = zeros(1,nbCFS);
idxEnd = nbCFS;
for k = 1:level
    j = lev2-k;
    idxBeg = idxEnd-3*mul*tmp(j)+1;
    idxB = idxBegs(k,:);
    idxE = idxB + sizeCFS(j,1:2)- 1;
    H = M(1:sizeCFS(j,1),idxB(2):idxE(2),:);
    V = M(idxB(1):idxE(1),1:sizeCFS(j,2),:);
    D = M(idxB(1):idxE(1),idxB(2):idxE(2),:);
    C(idxBeg:idxEnd) = [H(:)' , V(:)' , D(:)'];
    idxEnd = idxBeg-1;
end
A = M(1:sizeCFS(1,1),1:sizeCFS(1,2),:);
C(1:idxEnd) = A(:)';
