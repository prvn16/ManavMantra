function [pc,score,vp,r] = wpca(x,flagCENTER)
%WPCA Principal Component Analysis.
%   [PC,SCORE,VP,RANK] = WPCA(X,flagCENTER) returns the principal 
%   components of the matrix X in PC, the scores in SCORE, the  
%   eigenvalues of the covariance matrix of X in VP and the maximal
%   possible rank of X in RANK.
%   If flagCENTER is equal to true, then  X is centered.
%   [...] = WPCA(X) is equivalent to [...] = WPCA(X,true).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 11-Jan-2006.
%   Last Revision: 10-Feb-2006.
%   Copyright 1995-2006 The MathWorks, Inc.

if nargin<2 , flagCENTER = true; end
[n,p] = size(x);

% maximum possible rank of x.
r = min(n-1,p);

if flagCENTER
    % center columns.
    avg = mean(x);
    x = (x - avg(ones(n,1),:));
end

% perform SVD.
[dummy,singval,pc] = svd(x./sqrt(n-1),0);

% set scores and eigenvalues.
score = x*pc;
vp = diag(singval).^2;
