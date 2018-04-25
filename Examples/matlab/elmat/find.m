%FIND   Find indices of nonzero elements.
%   I = FIND(X) returns the linear indices corresponding to 
%   the nonzero entries of the array X.  X may be a logical expression. 
%   Use IND2SUB(SIZE(X),I) to calculate multiple subscripts from 
%   the linear indices I.
% 
%   I = FIND(X,K) returns at most the first K indices corresponding to 
%   the nonzero entries of the array X.  K must be a positive integer, 
%   but can be of any numeric type.
%
%   I = FIND(X,K,'first') is the same as I = FIND(X,K).
%
%   I = FIND(X,K,'last') returns at most the last K indices corresponding 
%   to the nonzero entries of the array X.
%
%   [I,J] = FIND(X,...) returns the row and column indices instead of
%   linear indices into X. This syntax is especially useful when working
%   with sparse matrices.  If X is an N-dimensional array where N > 2, then
%   J is a linear index over the N-1 trailing dimensions of X.
%
%   [I,J,V] = FIND(X,...) also returns a vector V containing the values
%   that correspond to the row and column indices I and J.
%
%   Example:
%      A = magic(3)
%      find(A > 5)
%
%   finds the linear indices of the 4 entries of the matrix A that are
%   greater than 5.
%
%      [rows,cols,vals] = find(speye(5))
%
%   finds the row and column indices and nonzero values of the 5-by-5
%   sparse identity matrix.
%
%   See also SPARSE, IND2SUB, RELOP, NONZEROS.

%   Copyright 1984-2005 The MathWorks, Inc.
%   Built-in function.

