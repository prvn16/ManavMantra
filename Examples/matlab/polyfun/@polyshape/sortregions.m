function PG = sortregions(pshape, varargin)
% SORTREGIONS Sort regions in polyshape
%
% PG = SORTREGIONS(pshape, Key, Direction) sorts the regions of pshape
% according to Key and Direction.
%
% Key can be one of the following:
%  'area' (default) - Sort by region area.
%  'perimeter' - Sort by region perimeter.
%  'numsides' - Sort by number of sides of the regions.
%  'centroid' - Sort by the distance from the centroid of each region to
%               the point (0,0).
%
% Direction can be one of the following:
%  'ascend' (default) - Sort regions in ascending order.
%  'descend' - Sort regions in descending order.
%
% PG = SORTREGIONS(pshape,'centroid',Direction,'ReferencePoint',point) 
% specifies a reference point by which to sort the regions of pshape when
% the sorting Key is 'centroid'. point is of the form [x y] where x is
% the x-coordinate of the reference point and y is the y-coordinate. By
% default, the reference point vector is [0 0].
%
% See also sortboundaries, translate, union, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

n = polyshape.checkArray(pshape);
args = polyshape.checkSortInput(varargin{:});
PG = pshape;
for i=1:numel(pshape)
    if pshape(i).isEmptyShape()
        continue;
    end
    PG(i).Underlying = sortregions(pshape(i).Underlying, args{:});
end
