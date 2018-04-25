function ind = nearestPoint(point, locations, metric)
%nearestPoint Find the index of the nearest point
%
%  nearestPoint(point, data) returns the index of the point in the 2D data
%  array that is closest to the provided point.  The data array should be
%  of size (2xN).
%
%  nearestPoint(point, data, metric) also specifies the metric to use when
%  calculting the distances between points.  The options are 'euclidean'
%  'x', and 'y'.  'x' and 'y' use the absolute distance in just the x and y
%  directions respectively while 'euclidean' uses the standard sum of the
%  squares.  

%  Copyright 2013-2014 The MathWorks, Inc.

if nargin<3
    % Default to euclidean distance
    metric = 'euclidean';
end

if ~all(isfinite(point)) || isempty(locations) || ~any(all(isfinite(locations),1))
    ind = [];
else
    switch metric
        case 'x'
            dist = abs((locations(1,:)-point(1)));
        case 'y'
            dist = abs((locations(2,:)-point(2)));
        otherwise
            % default to 'euclidean'
            dist = (locations(1,:)-point(1)).^2 + (locations(2,:)-point(2)).^2;
    end
    [~, ind] = min(dist);
end
