function t = trace(A)
%TRACE  Sum of diagonal elements.
%   TRACE(A) is the sum of the diagonal elements of A, which is
%   also the sum of the eigenvalues of A.
%
%   Class support for input A:
%      float: double, single

%   Copyright 1984-2011 The MathWorks, Inc. 

if ~ismatrix(A) || size(A,1)~=size(A,2)
  error(message('MATLAB:trace:square'));
end
t = full(sum(diag(A)));
