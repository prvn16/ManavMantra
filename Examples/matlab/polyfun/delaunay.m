%DELAUNAY Delaunay triangulation of a set of points in 2D/3D space
%   DELAUNAY is used to create a Delaunay triangulation of a set of points 
%   in 2D/3D space. A 2D Delaunay triangulation ensures that the circumcircle 
%   associated with each triangle contains no other point in its interior. 
%   This definition extends naturally to higher dimensions. 
%
%   TRI = DELAUNAY(X,Y) creates a 2D Delaunay triangulation of the points 
%   (X,Y), where X and Y are column-vectors. TRI is a matrix representing 
%   the set of triangles that make up the triangulation. The matrix is of
%   size mtri-by-3, where mtri is the number of triangles. Each row of TRI
%   specifies a triangle defined by indices with respect to the points.
%
%   TRI = DELAUNAY(X,Y,Z) creates a 3D Delaunay triangulation of the points
%   (X,Y,Z), where X, Y, and Z are column-vectors. TRI is a matrix 
%   representing the set of tetrahedra that make up the triangulation. The 
%   matrix is of size mtri-by-4, where mtri is the number of tetrahedra. 
%   Each row of TRI specifies a tetrahedron defined by indices with respect 
%   to the points.
%
%   TRI = DELAUNAY(X) creates a 2D/3D Delaunay triangulation from the 
%   point coordinates X. This variant supports the definition of points in 
%   matrix format. X is of size mpts-by-ndim, where mpts is the number of 
%   points and ndim is the dimension of the space where the points reside, 
%   2 <= ndim <= 3. The output triangulation is equivalent to that of the 
%   dedicated functions supporting the 2-input or 3-input calling syntax.
%
%   The DELAUNAY function produces an isolated triangulation; this is 
%   useful for applications like plotting surfaces via the TRISURF function. 
%   If you wish to query the triangulation; for example, to perform nearest 
%   neighbor, point location, or topology queries, then delaunayTriangulation
%   should be used instead.
%
%   Example 1:
%      x = [-0.5 -0.5 0.5 0.5]';
%      y = [-0.5 0.5 0.5 -0.5]';
%      tri = delaunay(x,y);
%      triplot(tri,x,y);
%      % Highlight the first triangle in red
%      tri1 = tri(1, [1:end 1]);
%      hold on
%      plot(x(tri1), y(tri1), 'r')
%
%   Example 2:
%      X = rand(15,3);
%      tri = delaunay(X);
%      tetramesh(tri,X);
%   
%   See also delaunayTriangulation, VORONOI, TRIMESH, TRISURF, TRIPLOT,
%            CONVHULL, DELAUNAYN, scatteredInterpolant.

%   Copyright 1984-2013 The MathWorks, Inc.
%   Built-in function.

