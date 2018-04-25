%RESHAPE Reshape array.
%   RESHAPE(X,M,N) or RESHAPE(X,[M,N]) returns the M-by-N matrix 
%   whose elements are taken columnwise from X. An error results 
%   if X does not have M*N elements.
%
%   RESHAPE(X,M,N,P,...) or RESHAPE(X,[M,N,P,...]) returns an 
%   N-D array with the same elements as X but reshaped to have 
%   the size M-by-N-by-P-by-.... The product of the specified
%   dimensions, M*N*P*..., must be the same as NUMEL(X).
%
%   RESHAPE(X,...,[],...) calculates the length of the dimension
%   represented by [], such that the product of the dimensions 
%   equals NUMEL(X). The value of NUMEL(X) must be evenly divisible 
%   by the product of the specified dimensions. You can use only one 
%   occurrence of [].
%
%   See also SQUEEZE, SHIFTDIM, COLON.

%   Copyright 1984-2013 The MathWorks, Inc.
%   Built-in function.

