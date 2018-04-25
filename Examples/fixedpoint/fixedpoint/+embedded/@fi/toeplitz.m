%TOEPLITZ Create toeplitz matrix
%   T = TOEPLITZ(A,B) returns a non-symmetric Toeplitz matrix having A as 
%   its first column and B as its first row. B is cast to the numerictype 
%   of A.
%
%   T = TOEPLITZ(B) returns the symmetric or Hermitian Toeplitz matrix 
%   formed from vector B, where B is the first row of the matrix. The 
%   numerictype and fimath properties associated with the leftmost input 
%   that is a fi object are applied to the output T.
%
%   Examples: 
%
%   % Overflow occurring due to cast of b to a's numerictype
%     format short g
%     a = fi([1 2 3],true,8,5)
%     b = fi([1 4 8],true,16,10)
%     c = toeplitz(a,b)
%   % Values 4 and 8 along upper-triangular portion of C saturate
%   % to 3.9688.
%
%   % Overflow not occurring due to cast of a to b's numerictype
%     a = fi([1 2 3],true,8,5)
%     b = fi([1 4 8],true,16,10)
%     c = toeplitz(b,a)
%   % Returns proper result without saturation.
%
%   % If one of the arguments of toeplitz is a built-in data type, it 
%   % is cast to the data type of the fi object.
%     a = fi([1 2 3],true,8,5)
%     x = [1 exp(1) pi] % displays x as [1 2.7183 3.1416]
%     c = toeplitz(a,x)
%     d = toeplitz(x,a)
%   % x being built-in, is cast to data type of a in both cases
%
%   See also TOEPLITZ, TRANSPOSE

%   Copyright 1999-2012 The MathWorks, Inc.
