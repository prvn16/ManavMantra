function [Idx, boundaryId, index] = nearestvertex(pshape, varargin)
% NEARESTVERTEX Find the nearest vertex of a polyshape
%
% [Idx, boundaryId, index] = NEARESTVERTEX(pshape, XY) returns the nearest
% vertex of a polyshape to the query points defined in XY. XY is a 2-column
% matrix whose first column contains the x-coordinates of the query points
% and second column contains the y-coordinates. Idx is the row number of the 
% nearest vertex from the Vertices property of pshape. boundaryId is the 
% boundary index of pshape corresponding to the nearest vertex. index is the 
% vertex index of boundary boundaryId. 
%
% [Idx, boundaryId, index] = NEARESTVERTEX(pshape, X, Y) defines the x- and
% y-coordinates of the query points with the vectors X and Y. X and Y must 
% have the same length.
%
% See also area, centroid, isinterior, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(2, 3);
polyshape.checkScalar(pshape);

param.allow_inf = false;
param.allow_nan = false;
param.one_point_only = false;
param.errorOneInput = 'MATLAB:polyshape:queryPoint1';
param.errorTwoInput = 'MATLAB:polyshape:queryPoint2';
param.errorValue = 'MATLAB:polyshape:queryPointFiniteValue';
[X, Y] = polyshape.checkPointArray(param, varargin{:});

if isEmptyShape(pshape)
    n = numel(X);
    Idx = zeros(n, 0);
    boundaryId = zeros(n, 0);
    index = zeros(n, 0);
    return;
end

V = [X Y];
[Idx, boundaryId, index] = nearestvertex(pshape.Underlying, V);
end
