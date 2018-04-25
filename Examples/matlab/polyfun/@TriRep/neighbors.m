%neighbors  Returns the simplex neighbor information
%
%   TriRep/neighbors will be removed in a future release.
%   Use triangulation/neighbors instead.
%
%   SN = neighbors(TR, SI) Returns the simplex neighbor information for 
%   the specified simplices SI. A simplex is a triangle/tetrahedron or
%   higher dimensional equivalent. SI is a column vector of simplex indices
%   that index into the triangulation matrix TR.Triangulation. 
%   SN is an m-by-n matrix, where m is of length(SI), the number of specified 
%   simplices, and n is the number of neighbors per simplex. Each row SN(i,:)
%   represents the neighbors of the simplex SI(i). If SI is not specified the
%   neighbor information for the entire triangulation is returned, where 
%   the neighbors associated with simplex i are defined by the i'th row of SN.
%
%   By convention, the simplex opposite vertex(j) of simplex SI(i) 
%   is SN(i,j). If a simplex has one or more boundary facets, the 
%   nonexistent neighbors are represented by NaN.
%
%   Example 1: Load a 2D triangulation and use the TriRep to compute the 
%              neighboring triangles.
%       load trimesh2d
%       % This loads triangulation tet and vertex coordinates X
%       trep = TriRep(tri,x,y)
%       triplot(trep);
%       trigroup = neighbors(trep,35)';
%       trigroup(end+1) = 35;
%       ic = incenters(trep, trigroup);
%       hold on
%       axis([-50 350 -50 350]);
%       axis equal;
%       trilabels = arrayfun(@(x) {sprintf('T%d', x)}, trigroup);
%       Htl = text(ic(:,1), ic(:,2), trilabels, 'FontWeight', 'bold', ...
%               'HorizontalAlignment', 'center', 'Color', 'red');
%       hold off
%
%   Example 2: Direct query of a 2D triangulation created using DelaunayTri
%       % Create a 2D Delaunay Triangulation
%       % from random points in the unit square.
%       x = rand(10,1)
%       y = rand(10,1)
%       dt = DelaunayTri(x,y)
%       % What are the neighbors of the first triangle
%       n1 = neighbors(dt, 1)
%
%
%   See also TriRep, DelaunayTri.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.