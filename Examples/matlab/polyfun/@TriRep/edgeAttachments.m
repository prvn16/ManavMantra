%edgeAttachments  Returns the simplices attached to the specified edges
%
%   TriRep/edgeAttachments will be removed in a future release.
%   Use triangulation/edgeAttachments instead.
%
%   SI = edgeAttachments(TR, V1, V2) Returns the simplices SI attached to the 
%   edges specified by (V1, V2). A simplex is a triangle/tetrahedron or
%   higher dimensional equivalent. SI is a vector cell array where each cell 
%   contains indices into the triangulation matrix; TR.Triangulation. 
%   (V1, V2) are column vectors of vertex indices into the array of points 
%   representing the vertex coordinates, TR.X. (V1, V2) represents the start 
%   and end vertices of the edges to be queried. 
%   SI is a cell array because the number of simplices associated with each 
%   edge can vary. 
%
%   SI = edgeAttachments(TR, EDGE)  Specifies the edge start and end 
%   points in matrix format, where EDGE is of size m-by-2, m being the 
%   number of edges to query.
%
%   Example 1: Load a 3D triangulation and use the TriRep to compute the 
%              tetrahedra attached to an edge.
%       load tetmesh
%       % This loads triangulation tet and vertex coordinates X
%       trep = TriRep(tet, X)
%       v1 = [15 21]'
%       v2 = [936 716]'
%       t = edgeAttachments(trep, v1, v2)
%       t{:}
%       % Alternatively, specify as edges
%       e = [v1 v2]
%       t = edgeAttachments(trep, e)
%       t{:}
%
%   Example 2: Direct query of a triangulation created using DelaunayTri
%       % Create a 2D Delaunay triangulation and query the triangles attached 
%       %  to edge(1,5)
%       x = [0 1 1 0 0.5]'
%       y = [0 0 1 1 0.5]'
%       dt = DelaunayTri(x,y)
%       t = edgeAttachments(dt, 1,5) 
%       t{:}
%
%
%   See also TriRep, DelaunayTri.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.