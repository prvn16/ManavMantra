% pointLocation  Locate the simplex containing the specified location
%
%    DelaunayTri/pointLocation will be removed in a future release.
%    Use delaunayTriangulation/pointLocation instead.
%
%    SI = pointLocation(DT, QX)  returns the indices SI of the enclosing 
%    simplex (triangle/tetrahedron, etc) for each query point location in QX.
%    The enclosing simplex for point QX(k,:) is SI(k). The matrix QX is of 
%    size mpts-by-ndim, mpts being the number of query points. SI is a 
%    column vector of length mpts. pointLocation returns NaN for all points 
%    outside the convex hull.
%
%    SI = pointLocation(DT, QX,QY) and SI = pointLocation (DT, QX,QY,QZ) 
%    allow the query point locations to be specified in alternative column 
%    vector format when working in 2D and 3D.
%
%    [SI, BC] = pointLocation(DT,...)  returns in addition, the Barycentric
%    coordinates BC. BC is a mpts-by-ndim matrix, each row BC(i,:) represents 
%    the Barycentric coordinates of QX(i,:) with respect to the enclosing
%    simplex SI(i).
%
%    Example 1:
%        % Point Location in 2D 	
%        X = rand(10,2)
%        dt = DelaunayTri(X)
%        % Find the triangles that contain the following query points
%        qrypts = [0.25 0.25; 0.5 0.5]
%        triids = pointLocation(dt, qrypts)
%
%    Example 2:
%        % Point Location in 3D plus barycentric coordinate evaluation 	
%        x = rand(10,1); y = rand(10,1); z = rand(10,1);
%        dt = DelaunayTri(x,y,z)
%        % Find the triangles that contain the following query points
%        qrypts = [0.25 0.25 0.25; 0.5 0.5 0.5]
%        [tetids, bcs] = pointLocation(dt, qrypts)
%
%    See also DelaunayTri, DelaunayTri.nearestNeighbor.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.