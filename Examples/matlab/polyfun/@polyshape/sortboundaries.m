function PG = sortboundaries(pshape, varargin)
% SORTBOUNDARIES Sort boundaries in polyshape
%
% PG = SORTBOUNDARIES(pshape, Key, Direction) sorts the boundaries of
% pshape according to Key and Direction.
%
% Key can be one of the following:
%  'area' (default) - Sort by boundary area.
%  'perimeter' - Sort by boundary perimeter.
%  'numsides' - Sort by number of sides of the boundaries.
%  'centroid' - Sort by the distance from the centroid of each boundary to
%               the point (0,0).
%
% Direction can be one of the following:
%  'ascend' (default) - Sort boundaries in ascending order.
%  'descend' - Sort boundaries in descending order.
%
% PG = SORTBOUNDARIES(pshape,'centroid',Direction,'ReferencePoint',point) 
% specifies a reference point by which to sort the boundaries of pshape 
% when the sorting Key is 'centroid'. point is of the form [x y] where 
% x is the x-coordinate of the reference point and y is the y-coordinate. 
% By default, the reference point vector is [0 0].
%
% Example:
% square = polyshape([-3 -3 3 3], [-3 3 3 -3]);
% angle = (0:0.05:2*pi)'; 
% XY1 = [cos(angle) sin(angle)];
% XY2 = [cos(angle) sin(angle)]*0.5 + [4 0];
% shape1 = addboundary(square, XY1);
% shape2 = addboundary(shape1, XY2);
% plot(shape2)
% shape3 = sortboundaries(shape2, 'area')
% area(shape2, 1:3)
% area(shape3, 1:3)
%
% See also sortregions, translate, union, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

n = polyshape.checkArray(pshape);
args = polyshape.checkSortInput(varargin{:});
PG = pshape;
for i=1:numel(pshape)
    if pshape(i).isEmptyShape()
        continue;
    end
    PG(i).Underlying = sortboundaries(pshape(i).Underlying, args{:});
end
