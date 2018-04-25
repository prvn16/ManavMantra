function [X, Y] = boundary(pshape, i)
% BOUNDARY Get x- and y-coordinates of a boundary
%
% [X, Y] = BOUNDARY(pshape) returns the x- and y-coordinates of each 
% boundary of pshape. The coordinates for the boundaries are delimited by
% NaN values in the vectors X and Y. 
%
% [X, Y] = BOUNDARY(pshape, I) returns the x- and y-coordinates of the I-th
% boundary of pshape.
%
% See also area, addboundary, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

polyshape.checkScalar(pshape);

if nargin == 1
    if pshape.isEmptyShape()
        X = zeros(0, 1);
        Y = zeros(0, 1);
        return;
    end
    II = 1:pshape.numboundaries;
else
    polyshape.checkEmpty(pshape);
    II = polyshape.checkIndex(pshape, i);
end

[X, Y] = boundary(pshape.Underlying, II);

end