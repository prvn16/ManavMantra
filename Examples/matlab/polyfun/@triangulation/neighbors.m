%neighbors  Neighbors to a triangle or tetrahedron
% TN = neighbors(TR, TI) returns the neighbor information for the specified
%     triangles/tetrahedra TI, where TI is a column vector of triangle or 
%     tetrahedra IDs. These IDs correspond to the row number of the triangulation 
%     connectivity matrix TR.ConnectivityList.
%     TN is an m-by-n matrix, where m is of length(TI), the number of specified
%     triangles/tetrahedra, and n is the number of neighbors of each. Each row TN(i,:)
%     represents the neighbors of TI(i). If TI is not specified the neighbor 
%     information for the entire triangulation is returned, where the neighbors 
%     associated with T(i) are defined by the i'th row of TN.
%
%     By convention, the neighbor opposite vertex(j) of triangle/tetrahedron TI(i)
%     is TN(i,j). If a triangle/tetrahedron has one or more boundary facets, the
%     nonexistent neighbors are represented by NaN.
%
%   Example 1: Load a 2D triangulation and use the triangulation to compute the
%              neighboring triangles.
%       load trimesh2d
%       % This loads triangulation tet and vertex coordinates X
%       trep = triangulation(tri,x,y)
%       triplot(trep);
%       trigroup = neighbors(trep,35)';
%       trigroup(end+1) = 35;
%       ic = incenter(trep, trigroup);
%       hold on
%       axis([-50 350 -50 350]);
%       axis equal;
%       trilabels = arrayfun(@(x) {sprintf('T%d', x)}, trigroup);
%       Htl = text(ic(:,1), ic(:,2), trilabels, 'FontWeight', 'bold', ...
%               'HorizontalAlignment', 'center', 'Color', 'red');
%       hold off
%
%   Example 2: Direct query of a 2D triangulation created using delaunayTriangulation
%       % Create a 2D Delaunay Triangulation
%       % from random points in the unit square.
%       x = rand(10,1)
%       y = rand(10,1)
%       dt = delaunayTriangulation(x,y)
%       % What are the neighbors of the first triangle
%       n1 = neighbors(dt, 1)
%
%   See also triangulation, delaunayTriangulation.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.