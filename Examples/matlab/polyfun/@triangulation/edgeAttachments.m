%edgeAttachments  Triangles or tetrahedra attached to an edge
% TI = edgeAttachments(TR, V1, V2) returns the triangles or tetrahedra TI 
%     attached to the edges specified by the vertex IDs (V1, V2). TI is a 
%     vector cell array where each cell contains triangle or tetrahedron IDs 
%     corresponding to the row numbers of the triangulation connectivity 
%     matrix TR.ConnectivityList. TI is a cell array because the number of 
%     triangles/tetrahedra associated with each edge can vary. 
%     (V1, V2) represents the start and end vertices of the edges to be queried. 
%     These are column vectors of vertex IDs, where a vertex ID corresponds 
%     to the row number into TR.Points. 
%
%   Example 1: Load a 3D triangulation and use the triangulation to compute the 
%              tetrahedra attached to an edge.
%       load tetmesh
%       % This loads triangulation tet and vertex coordinates X
%       trep = triangulation(tet, X)
%       v1 = [15 21]'
%       v2 = [936 716]'
%       t = edgeAttachments(trep, v1, v2)
%       t{:}
%       % Alternatively, specify as edges
%       e = [v1 v2]
%       t = edgeAttachments(trep, e)
%       t{:}
%
%   Example 2: Direct query of a triangulation created using delaunayTriangulation
%       % Create a 2D Delaunay triangulation and query the triangles attached 
%       %  to edge(1,5)
%       x = [0 1 1 0 0.5]'
%       y = [0 0 1 1 0.5]'
%       dt = delaunayTriangulation(x,y)
%       t = edgeAttachments(dt, 1,5) 
%       t{:}
%
%   See also triangulation, delaunayTriangulation.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.