function [sortedk,ind] = maxk(this,k,varargin)
%MAXK   Return largest K elements from input
%   B = MAXK(A,K) returns output B that is a datetime array:
%   - For vectors, MAXK(A,K) returns the K largest elements of A.
%   - For matrices, MAXK(A,K) returns the K largest elements for each column of A.
%   - For N-D arrays, MAXK(A,K) returns K largest elements along the first non-singleton dimension.
%
%   B = MAXK(A,K,DIM) also specifies a dimension DIM to operate along.
%
%   [B,I] = MAXK(...) also returns an index I which specifies how the
%   K elements of A were rearranged to obtain the output B:
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

% Lexicographic sort of complex data
if nargout < 2
    newdata = maxk(this.data,k,varargin{:},'ComparisonMethod','real');
else
    [newdata,ind] = maxk(this.data,k,varargin{:},'ComparisonMethod','real');
end

sortedk = this;
sortedk.data = newdata;