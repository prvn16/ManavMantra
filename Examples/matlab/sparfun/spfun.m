function f = spfun(fun,s)
%SPFUN Apply function to nonzero matrix elements.
%   F = SPFUN(FUN,S) evaluates the function FUN on the nonzero 
%   elements of S.
%
%   Example
%      FUN can be specified using @:
%         S = sprand(30,30,0.2);
%         F = spfun(@exp,S);
%      has the same sparsity pattern as S (except for underflow), 
%      whereas EXP(S) has 1's where S has 0's.    
%
%   See also FUNCTION_HANDLE.

%   Copyright 1984-2010 The MathWorks, Inc.

if ~ismatrix(s)
    error(message('MATLAB:spfun:ndInput'));
end
[i,j,x] = find(s);
[m,n] = size(s);
f = sparse(i,j,feval(fun,x),m,n);

