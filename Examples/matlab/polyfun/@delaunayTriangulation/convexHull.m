% convexHull  Convex hull
% K = convexHull(DT)  returns the indices of the vertices on the convex hull.
%      The vertex indices correspond to the row numbers of DT.Points.
%      For 2-D triangulations, K is a column vector of length numf, otherwise 
%      K is a matrix of size numf-by-3, numf being the number of  facets on 
%      the convex hull.
%
%      [K AV] = convexHull(DT) returns in addition, the area/volume bounded
%      by the convex hull.
%
%    Example 1: Compute the convex hull of a set of random points located
%               within a unit square in 2D space.
%        x = rand(10,1)
%        y = rand(10,1)
%        dt = delaunayTriangulation(x,y)
%        k = convexHull(dt)
%        plot(dt.Points(:,1),dt.Points(:,2), '.', 'markersize',10); hold on;
%        plot(dt.Points(k,1),dt.Points(k,2), 'r'); hold off;
%
%    Example 2: Compute the convex hull of a set of random points located
%            within a unit cube in 3D space, and the volume bounded by the
%            convex hull.
%        X = rand(25,3)
%        dt = delaunayTriangulation(X)
%        [ch v] = convexHull(dt)
%        trisurf(ch, dt.Points(:,1),dt.Points(:,2),dt.Points(:,3), 'FaceColor', 'cyan')
%
% See also delaunayTriangulation, trisurf.

% Copyright 2012 The MathWorks, Inc.
% Built-in function.
