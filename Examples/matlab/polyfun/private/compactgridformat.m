function tf = compactgridformat(varargin)
% COMPACTGRIDFORMAT true if inputs are vectors of mixed orientation
%   TF = COMPACTGRIDFORMAT(X1, X2,X3,...Xn) returns true if X1, X2,X3,...Xn
%   are vectors and X1 and X2 have mixed orientations. This arrangement of 
%   vectors is used to implicitly define a grid in the INTERP2, INTERP3, and 
%   INTERPN functions.

%   Copyright 2012-2013 The MathWorks, Inc.

tf = all(cellfun(@isvector,varargin));
if tf && nargin > 1
    ns = cellfun(@(x)size(x)~=1, varargin, 'UniformOutput', false);
    tf = ~isequal(ns{:});
end

