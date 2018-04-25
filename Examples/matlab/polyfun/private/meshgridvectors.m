function [varargout] = meshgridvectors(V)
% MESHGRIDVECTORS vectors for creating a default MESHGRID 
%   [xg, yg] = MESHGRIDVECTORS(V) creates grid vectors xg = 1:N and yg = 1:M,
%   where size(V) is M-by-N. The grid vectors (xg, yg) can be passed to 
%   MESHGRID to give [X,Y] = MESHGRID(xg,yg), such that the size of X and Y 
%   equals the size of V.
%
%   [xg, yg, zg] = MESHGRIDVECTORS(V) creates grid vectors xg = 1:N, yg = 1:M,
%   and zg = 1:p, where size(V) is M-by-N-by-P. The grid vectors (xg, yg, Zg) 
%   can be passed to MESHGRID to give [X,Y,Z] = MESHGRID(xg,yg,zg), such that 
%   the size of X and Y and Z equals the size of V.
%

%   Copyright 2011 The MathWorks, Inc.

ndimsv = ndims(V);
varargout = cell(1,ndimsv);
sizev = size(V);
varargout{1} = 1:sizev(2); 
varargout{2} = 1:sizev(1);
if ndimsv == 3
    varargout{3} = 1:sizev(3); 
end

