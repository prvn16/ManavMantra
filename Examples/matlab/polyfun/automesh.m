function tf = automesh(varargin)
%AUTOMESH returns true if the inputs should be passed to meshgrid.
%   AUTOMESH(X,Y,...) returns true if all the inputs are vectors and the
%   orientations of all the inputs are not the same. 

%   Copyright 1984-2005 The MathWorks, Inc.

tf = false;
if all(cellfun(@isvector,varargin))
   % Location of non-singleton dimensions
   ns = cellfun(@(x)size(x)~=1, varargin, 'UniformOutput', false);
   % True if not all inputs have the same non-singleton dimension. 
   tf = ~isequal(ns{:});
end

