function A = forsythe(n, alpha, lambda, classname)
%FORSYTHE Forsythe matrix (perturbed Jordan block).
%   A = GALLERY('FORSYTHE',N,ALPHA,LAMBDA) is the N-by-N matrix
%   equal to the Jordan block with eigenvalue LAMBDA with the
%   exception that A(N,1) = ALPHA.
%   ALPHA defaults to SQRT(EPS) and LAMBDA to 0.
%
%   The characteristic polynomial of A is given by
%      det(A-t*I) = (LAMBDA-t)^N - ALPHA*(-1)^N.

%   Copyright 1984-2005 The MathWorks, Inc.

if isempty(alpha), alpha = sqrt(eps(classname)); end
if isempty(lambda), lambda = zeros(classname); end

A = jordbloc(n, lambda, classname);
A(n,1) = alpha;
