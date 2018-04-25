%freeBoundary  Returns the facets referenced by only one simplex
%
%   TriRep/freeBoundary will be reomved in a future release.
%   Use triangulation/freeBoundary instead.
%
%   FF = freeBoundary(TR)  Returns a matrix FF that represents the free 
%   boundary facets of the triangulation. A facet is on the free boundary 
%   if it is referenced by only one simplex (triangle/tetrahedron, etc).
%   FF is of size m-by-n, where m is the number of boundary facets and n is
%   the number of vertices per facet. The vertices of the facets index into
%   the array of points representing the vertex coordinates TR.X. The array 
%   FF could be empty as in the case of a triangular mesh representing the 
%   surface of a sphere.
%
%   [FF XF] = freeBoundary(TR)  Returns a matrix of free boundary facets FF
%   that has vertices defined in terms of a compact array of coordinates XF.
%   XF is of size m-by-ndim where m is the number of free facets, and ndim
%   is the dimension of the space where the triangulation resides.
%
%   Example 1: Load a 3D triangulation and use the TriRep to compute the 
%              boundary triangulation.
%       load tetmesh
%       % This loads triangulation tet and vertex coordinates X
%       trep = TriRep(tet, X)
%       [tri xf] = freeBoundary(trep);
%       %Plot the boundary triangulation
%       trisurf(tri, xf(:,1),xf(:,2),xf(:,3), 'FaceColor', 'cyan', 'FaceAlpha', 0.8); 
%
%   Example 2:Direct query of a 2D triangulation created using DelaunayTri
%       % Plot the mesh and display the free boundary edges in red.
%       x = rand(20,1)
%       y = rand(20,1)
%       dt = DelaunayTri(x,y)
%       fe = freeBoundary(dt)';
%       triplot(dt);
%       hold on ; plot(x(fe), y(fe), '-r', 'LineWidth',2) ; hold off ;
%       % In this instance the free edges correspond to the convex hull of
%       % (x, y).
%
%
%   See also TriRep.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.
