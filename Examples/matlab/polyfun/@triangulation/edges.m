%edges  Triangulation edges
% E = edges(TR) returns the edges in the triangulation in an n-by-2
%     matrix of vertex IDs, n being the number of edges. The vertex IDs 
%     corresponds to the row numbers into TR.Points.
%
%   Example 1:
%       % Load a 2D triangulation and use the triangulation
%       % to construct a set of edges.
%       load trimesh2d
%       % This loads triangulation tri and vertex coordinates x, y
%       trep = triangulation(tri, x,y)
%       e = edges(trep)
%
%       % Direct query of a 2D Delaunay triangulation created using
%       % delaunayTriangulation. Construct the set of edges as in the previous case.
%       X = rand(10,2)
%       dt = delaunayTriangulation(X)
%       e = edges(dt)
%
%
%   See also triangulation, delaunayTriangulation.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.