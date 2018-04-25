% alphaTriangulation - Triangulation that fills the alpha shape
%    TRI = alphaTriangulation(SHP) returns a triangulation TRI that defines
%    the domain of the alpha shape. TRI is matrix is of size mtri-by-nv, 
%    where mtri is the number of triangles or tetrahedra within the alpha 
%    shape and nv is the number of vertices - 3 or 4. Each row specifies a 
%    triangle or tetrahedron defined by vertex IDs - the row numbers of the 
%    Points matrix.
%
%    TRI = alphaTriangulation(SHP, REGIONID) returns a triangulation TRI 
%    that defines a region of the alpha shape whose ID is REGIONID
%    and 1 <= REGIONID <= numRegions(SHP).
% 
%    [TRI, P] = alphaTriangulation(...) returns a triangulation TRI that has 
%    vertices defined in terms of a compact array of coordinates P.
%    P is of size nump-by-ndim where nump is the number of points in the 
%    alpha shape and 2 <= ndim <= 3.
%    
%    Example 1: Compute the alpha shape of a set of 2D points
%               and diaplay the alpha shape triangulation.
%      % Create a set of points (x,y)
%      th = (pi/12:pi/12:2*pi)';
%      x1 = [reshape(cos(th)*(1:5), numel(cos(th)*(1:5)),1); 0];
%      y1 = [reshape(sin(th)*(1:5), numel(sin(th)*(1:5)),1); 0];
%      x = [x1; x1+15;];
%      y = [y1; y1];
%      % Use alphaShape to create a polygon that envelops the points.
%      % An alpha value of 2 works well for this data set.
%      shp = alphaShape(x,y,2)
%      % Get the triangulation of the shape
%      [tri, p] = alphaTriangulation(shp);
%      figure
%      triplot(tri,p(:,1),p(:,2))
%      axis equal
%
%    Example 2: Compute the alpha shape of a set of 3D points
%               and recover the triangulation that makes up the shape.
%      % Create a set of points P 
%      [x1, y1, z1] = sphere(24);
%      x1 = x1(:);
%      y1 = y1(:);
%      z1 = z1(:);
%      x2 = x1+5;
%      P = [x1 y1 z1; x2 y1 z1];
%      P = unique(P,'rows');
%      % Plot the points
%      plot3(P(:,1),P(:,2),P(:,3),'.')
%      axis equal
%      % Use alphaShape to create a polyhedron that envelops the points
%      % An alpha value of 1 works well for this data set.
%      figure
%      shp = alphaShape(P,1)
%      plot(shp)
%      % Recover the triangulation.
%      tri = alphaTriangulation(shp);
%      % The number of tetrahedra in the triangulation is
%      numtetrahedra = size(tri,1)
%
%    See also alphaShape, alphaShape.Alpha, alphaShape.plot, triangulation.

% Copyright 2013-2014 The MathWorks, Inc.