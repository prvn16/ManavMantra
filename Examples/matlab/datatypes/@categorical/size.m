function varargout = size(a,dim)
%SIZE Size of a categorical array.
%   D = SIZE(A), for an M-by-N categorical matrix A, returns the two-element
%   row vector D = [M,N] containing the number of rows and columns in the
%   matrix.  For N-D categorical arrays, SIZE(A) returns a 1-by-N vector of
%   dimension lengths.  Trailing singleton dimensions are ignored.
%
%   [M,N] = SIZE(A), for a categorical matrix A, returns the number of rows
%   and columns in A as separate output variables. 
%   
%   [M1,M2,M3,...,MN] = SIZE(A), for N>1, returns the sizes of the first N 
%   dimensions of the categorical array A.  If the number of output arguments
%   N does not equal NDIMS(A), then for:
%
%   N > NDIMS(A), SIZE returns ones in the "extra" variables, i.e., outputs
%                 NDIMS(A)+1 through N.
%   N < NDIMS(A), MN contains the product of the sizes of dimensions N
%                 through NDIMS(A).
%  
%   M = SIZE(A,DIM) returns the length of the dimension specified by the
%   scalar DIM.  For example, SIZE(A,1) returns the number of rows. If DIM >
%   NDIMS(A), M will be 1.
%
%   See also LENGTH, NDIMS, NUMEL.

%   Copyright 2006-2013 The MathWorks, Inc. 

% Call the built-in to ensure correct dispatching regardless of what's in dim
if nargin == 1
    varargout = cell(1,max(nargout,1));
    [varargout{:}] = builtin('size',a.codes);
else
    varargout = cell(1);
    varargout{:} = builtin('size',a.codes,dim);
end
