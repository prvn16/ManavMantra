% convexHull  Returns the convex hull
%
%    DelaunayTri/convexHull will be removed in a future release.
%    Use delaunayTriangulation/convexHull instead.
%
%    K = convexHull(DT)  returns the indices into the array of points DT.X 
%    that correspond to the vertices of the convex hull. If the points lie 
%    in 2D space, K is a column vector of length numf, otherwise K is a 
%    matrix of size numf-by-ndim, numf being the number of facets in the 
%    convex hull, and ndim the dimension of the space where the points reside.
%
%    [K AV] = convexHull(DT) returns in addition, the area/volume bounded
%    by the convex hull.
%
%    Example 1: Compute the convex hull of a set of random points located 
%               within a unit square in 2D space.
%        x = rand(10,1)
%        y = rand(10,1)
%        dt = DelaunayTri(x,y)
%        k = convexHull(dt)
%        plot(dt.X(:,1),dt.X(:,2), '.', 'markersize',10); hold on;
%        plot(dt.X(k,1),dt.X(k,2), 'r'); hold off;
%
%    Example 2: Compute the convex hull of a set of random points located 
%            within a unit cube in 3D space, and the volume bounded by the
%            convex hull.
%        X = rand(25,3)
%        dt = DelaunayTri(X)
%        [ch v] = convexHull(dt)
%        trisurf(ch, dt.X(:,1),dt.X(:,2),dt.X(:,3), 'FaceColor', 'cyan')
%
% See also DelaunayTri, trisurf.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.