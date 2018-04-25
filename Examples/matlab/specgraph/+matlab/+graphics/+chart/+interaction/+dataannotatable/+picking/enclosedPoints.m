function ind = enclosedPoints(polygon, vertices)
%enclosedPoints Find the indices of the enclosed points
%
%  enclosedPoints(polygon, data) returns the indices of the points in the
%  2D data array that are enclosed by the provided polygon. The data array
%  should be of size (2xN).

%  Copyright 2013-2014 The MathWorks, Inc.

if ~all(isfinite(polygon(:)))
    ind = zeros(1,0);
    return
end

% Look for points that are inside the polygon
if isequal(size(polygon),[2 4]) || isequal(size(polygon),[2 5])
    minX = min(polygon(1,:));
    maxX = max(polygon(1,:));
    minY = min(polygon(2,:));
    maxY = max(polygon(2,:));
    delta = polygon;
    delta(1,polygon(1,:)==minX) = 0;
    delta(1,polygon(1,:)==maxX) = 0;
    delta(2,polygon(2,:)==maxY) = 0;
    delta(2,polygon(2,:)==minY) = 0;
    
    if all(delta(:)==0)
        % The polygon is a rectangle and we can do a fast bounds test
        ind = find(vertices(1,:)>=minX & vertices(1,:)<=maxX & ...
            vertices(2,:)>=minY & vertices(2,:)<=maxY);
    else
        ind = brushing.select.inpolygon(polygon, vertices);
    end
else
    ind = brushing.select.inpolygon(polygon, vertices);
end
