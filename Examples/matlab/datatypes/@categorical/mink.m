function [b,i] = mink(a,k,varargin)
%MINK   Return smallest K categories from input
%   B = MINK(A,K) returns output B that is a categorical array:
%   - For vectors, MINK(A,K) returns the K smallest categories of A.
%   - For matrices, MINK(A,K) returns the K smallest categories for each column of A.
%   - For N-D arrays, MINK(A,K) returns K smallest categories along the first non-singleton dimension.
%
%   B = MINK(A,K,DIM) also specifies a dimension DIM to operate along.
%
%   [B,I] = MINK(...) also returns an index I which specifies how the
%   K categories of A were rearranged to obtain the output B:
%   - If A is a vector, then B = A(I).  
%   - If A is an m-by-n matrix and DIM = 1, then
%       for j = 1:n, B(:,j) = A(I(:,j),j); end
%
%   See also MAXK, SORT, TOPKROWS, MIN.

%   Copyright 2017 The MathWorks, Inc. 

if ~isnumeric(k)
    error(message('MATLAB:topk:InvalidK'));
end

for ii = 1:(nargin-2) % ComparisonMethod not supported.
    if matlab.internal.math.checkInputName(varargin{ii},{'ComparisonMethod'})
        error(message('MATLAB:mink:InvalidAbsRealType'));
    end
end

if ~isempty(varargin) && ~isnumeric(varargin{1})
    error(message('MATLAB:topk:notPosInt'));
end

if ~a.isOrdinal
    error(message('MATLAB:categorical:NotOrdinal'));
end

acodes = a.codes;
acodes(acodes == categorical.undefCode) = invalidCode(acodes); % Set invalidCode

[bcodes,i] = mink(acodes,k,varargin{:});
bcodes(bcodes == invalidCode(bcodes)) = a.undefCode; % set invalidCode back to <undefined> code

b = a; % preserve subclass
b.codes = bcodes;
