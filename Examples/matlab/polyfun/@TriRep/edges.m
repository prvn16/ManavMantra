%edges  returns the edges in the triangulation
%
%   TriRep/edges will be removed in a future release.
%   Use triangulation/edges instead.
%
%   E = edges(TR) 	Returns the edges in the triangulation in an n-by-2 
%   matrix, n being the number of edges. The vertices of the edges index 
%   into TR.X, the array of points representing the vertex coordinates.
%
%   Example 1:
%       % Load a 2D triangulation and use the TriRep
%       % to construct a set of edges.
%       load trimesh2d
%       % This loads triangulation tri and vertex coordinates x, y
%       trep = TriRep(tri, x,y)
%       e = edges(trep)
%
%       % Direct query of a 2D Delaunay triangulation created using
%       % DelaunayTri. Construct the set of edges as in the previous case.
%       X = rand(10,2)
%       dt = DelaunayTri(X)
%       e = edges(dt)       
%
%
%   See also TriRep, DelaunayTri.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.