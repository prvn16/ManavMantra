function [b,i] = maxk(a,k,varargin)
%MAXK   Return largest K categories from input
%   B = MAXK(A,K) returns output B that is a categorical array:
%   - For vectors, MAXK(A,K) returns the k largest categories of A.
%   - For matrices, MAXK(A,K) returns the k largest categories for each column of A.
%   - For N-D arrays, MAXK(A,K) returns k largest categories along the first non-singleton dimension.
%
%   B = MAXK(A,K,DIM) also specifies a dimension DIM to operate along.
%
%   [B,I] = MAXK(...) also returns an index I which specifies how the
%   K categories of A were rearranged to obtain the output B:
%   - If A is a vector, then B = A(I).  
%   - If A is an m-by-n matrix and DIM = 1, then
%       for j = 1:n, B(:,j) = A(I(:,j),j); end
%
%   See also MINK, SORT, TOPKROWS, MAX.

%   Copyright 2017 The MathWorks, Inc. 

if ~isnumeric(k)
    error(message('MATLAB:topk:InvalidK'));
end

for ii = 1:(nargin-2) % ComparisonMethod not supported.
    if matlab.internal.math.checkInputName(varargin{ii},{'ComparisonMethod'})
        error(message('MATLAB:maxk:InvalidAbsRealType'));
    end
end

if ~isempty(varargin) && ~isnumeric(varargin{1})
    error(message('MATLAB:topk:notPosInt'));
end

if ~a.isOrdinal
    error(message('MATLAB:categorical:NotOrdinal'));
end

acodes = a.codes;
[bcodes,i] = maxk(acodes,k,varargin{:});

b = a; % preserve subclass
b.codes = bcodes;
