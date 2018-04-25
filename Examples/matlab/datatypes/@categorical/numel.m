function e = numel(a,varargin)
%NUMEL Number of elements in a categorical array.
%   N = NUMEL(A) returns the number of elements in the categorical array A.
%
%   N = NUMEL(A, VARARGIN) returns the number of subscripted elements, N, in
%   A(index1, index2, ..., indexN), where VARARGIN is a cell array whose
%   elements are index1, index2, ... indexN.
%
%   See also SIZE.

%   Copyright 2006-2013 The MathWorks, Inc. 

% Call the built-in to ensure correct dispatching regardless of what's in varargin
e = builtin('numel',a.codes,varargin{:});
