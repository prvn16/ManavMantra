function K = kron(A,B)
%KRON   Kronecker tensor product.
%   KRON(X,Y) is the Kronecker tensor product of X and Y.
%   The result is a large matrix formed by taking all possible
%   products between the elements of X and those of Y. For
%   example, if X is 2 by 3, then KRON(X,Y) is
%
%      [ X(1,1)*Y  X(1,2)*Y  X(1,3)*Y
%        X(2,1)*Y  X(2,2)*Y  X(2,3)*Y ]
%
%   If either X or Y is sparse, only nonzero elements are multiplied
%   in the computation, and the result is sparse.
%
%   Class support for inputs X,Y:
%      float: double, single
%      integers: uint8, int8, uint16, int16, uint32, int32, uint64, int64

%   Thanks to Bruno Luong for full matrices implementation. 
%   See license.txt for license information.
%   Thanks to Paul Fackler and Jordan Rosenthal for previous versions.
%   Copyright 1984-2016 The MathWorks, Inc. 

if ~ismatrix(A) || ~ismatrix(B)
    error(message('MATLAB:kron:TwoDInput'));
end

[ma,na] = size(A);
[mb,nb] = size(B);

if ~issparse(A) && ~issparse(B)
   % Both inputs full, result is full.
   A = reshape(A,[1 ma 1 na]);
   B = reshape(B,[mb 1 nb 1]);
   K = reshape(A.*B,[ma*mb na*nb]);
else
   % At least one input is sparse, result is sparse.
   K = matlab.internal.sparse.kronSparse(sparse(A), sparse(B));
end
