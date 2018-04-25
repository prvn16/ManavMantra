function [sizeCFS,sizesUTL] = getsizes(level,SizeINI)
%GETSIZES Returns the sizes of wavelet coefficients families.
%   [sizeCFS,sizesUTL] = GETSIZES(LEVEL,SizeINI)
%   GETSIZES is used by all Progressive Coefficients Significance
%   Methods (PCSM).
    
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 10-Mar-2004.
%   Last Revision: 05-Apr-2008.
%   Copyright 1995-2008 The MathWorks, Inc.

sizeCFS = zeros(level+2,2);
sizeCFS(end,:) = SizeINI;
for k=1:level
    sizeCFS(end-k,:) = ceil(sizeCFS(end-k+1,:)/2);
end
sizeCFS(1,:) = sizeCFS(2,:);
sizesUTL = kron(sizeCFS(1,:),2.^(0:level)');
