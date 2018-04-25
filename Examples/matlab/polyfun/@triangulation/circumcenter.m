%circumcenter  Circumcenter of triangle or tetrahedron
% CC = circumcenter(TR, TI) returns the coordinates of the circumcenter
%     of each triangle or tetrahedron in TI.
%     TI is a column vector of triangle or tetrahedron IDs corresponding to
%     the row numbers of the triangulation connectivity matrix TR.ConnectivityList.
%     CC is an m-by-n matrix, where m is of length(TI), the number of specified
%     triangles/tetrahedra, and n is the spatial dimension 2 <= n <= 3.
%     Each row CC(i,:) represents the coordinates of the circumcenter
%     of TI(i). If TI is not specified the circumcenter information for
%     the entire triangulation is returned, where the circumcenter associated
%     with triangle/tetrahedron i is the i'th row of CC.
%
%     [CC RCC] = circumcenter(TR, TI) returns in addition, the corresponding
%     radius of the circumscribed circle/sphere. RCC is a vector of length
%     length(TI), the number of specified triangles/tetrahedra.
%
%   Example 1: Load a 2D triangulation and use the triangulation to compute the
%              circumcenters.
%       load trimesh2d
%       % This loads triangulation tri and vertex coordinates  x, y
%       trep = triangulation(tri, x,y)
%       cc = circumcenter(trep);
%       triplot(trep);
%       axis([-50 350 -50 350]);
%       axis equal;
%       hold on; plot(cc(:,1),cc(:,2),'*r'); hold off;
%       % The circumcenters represent points on the medial axis of the polygon.
%
%   Example 2: Direct query of a 3D triangulation created using delaunayTriangulation
%	           Compute the circumcenters of the first five tetrahedra.
%       X = rand(10,3);
%       dt = delaunayTriangulation(X);
%       [cc rcc] = circumcenter(dt, [1:5]')
%
%   See also triangulation, triangulation.incenter, delaunayTriangulation.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.