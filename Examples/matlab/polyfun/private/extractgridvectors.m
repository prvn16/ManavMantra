function X = extractgridvectors(varargin)
% EXTRACTGRIDVECTORS inverse of NDGRID
%   X = EXTRACTGRIDVECTORS(X1, X2, X3,...,Xn) returns a cell array of
% grid vectors X such that [X1, X2, X3,...,Xn] = NDGRID(X{:})
%
%   See also NDGRID
%

%   Copyright 2012 The MathWorks, Inc.

X = varargin;
for i = find(~cellfun(@isvector,varargin))
    ind(1:nargin) = {1};
    ind{i} = ':';
    X{i} = varargin{i}(ind{:});
    X{i} = X{i}(:); % Make sure it's a column
end

