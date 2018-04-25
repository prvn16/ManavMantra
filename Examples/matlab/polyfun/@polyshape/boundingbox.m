function [xLimit, yLimit] = boundingbox(pshape, idx)
% BOUNDINGBOX Find the bounding box of a polyshape
%
% [xLimit, yLimit] = boundingbox(pshape) returns the x and y bounds that 
% define the smallest rectangle enclosing a polyshape. The first
% coordinates of xLimit and yLimit are the lower x and y bounds, and the 
% second coordinates are the upper bounds.
%
% When pshape is an array of polyshapes, boundingbox returns the limits 
% that enclose all polyshape elements.
%
% [xLimit, yLimit] = boundingbox(pshape, I) returns the bounding box of the 
% I-th boundary. If I is a vector of indices, then boundingbox returns the 
% limits enclosing all boundaries indexed by I. This syntax is only supported
% when pshape is a scalar polyshape.
%
% See also addboundary, centroid, convhull, polyshape

% Copyright 2016-2017 The MathWorks, Inc.

polyshape.checkConsistency(pshape, nargin);

if nargin == 1
    %n = polyshape.checkArray(pshape);
    dd = realmax('double');
    minx = dd;
    miny = dd;
    maxx = -dd;
    maxy = -dd;

    valid_bb = false;
    for i=1:numel(pshape)
        if pshape(i).isEmptyShape()
            continue;
        end
        valid_bb = true;
        [xL, yL] = boundingbox(pshape(i).Underlying);
        minx = min(minx, xL(1));
        maxx = max(maxx, xL(2));
        miny = min(miny, yL(1));
        maxy = max(maxy, yL(2));
    end
    if valid_bb
        xLimit = [minx maxx];
        yLimit = [miny maxy];        
    else
        xLimit = zeros(0, 2);
        yLimit = zeros(0, 2);
    end
else
    polyshape.checkScalar(pshape);
    polyshape.checkEmpty(pshape);
    II = polyshape.checkIndex(pshape, idx);
    [xLimit, yLimit] = boundingbox(pshape.Underlying, II);
end
