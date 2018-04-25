%isEdge  Tests whether a pair of vertices are joined by an edge
%
%   TriRep/isEdge will be removed in a future release.
%   Use triangulation/isConnected instead.
%
%   TF = isEdge(TR, V1, V2) 	Returns an array of 1/0 (true/false) flags,
%   where each entry TF(i) is true if V1(i), V2(i) is an edge in the 
%   triangulation. V1, V2 are column vectors representing the indices of the
%   vertices in the mesh, that is, indices into the vertex coordinate arrays.
%   TF = isEdge(TR, EDGE) 	Specifies the edge start and end indices in 
%   matrix format where EDGE is of size n-by-2, n being the number of
%   query edges.
%
%   Example 1:
%       % Load a 2D triangulation and use the TriRep to query the
%       % presence of an edge between a pair of points.
%       load trimesh2d
%       % This loads triangulation tri and vertex coordinates x, y
%       trep = TriRep(tri, x,y); 
%       triplot(trep);
%       vxlabels = arrayfun(@(n) {sprintf('P%d', n)}, [3 117 164]');
%       Hpl = text(x([3 117 164]), y([3 117 164]), vxlabels, 'FontWeight', ...
%                    'bold', 'HorizontalAlignment',...
%                   'center', 'BackgroundColor', 'none');
%       axis([-50 350 -50 350]);
%       axis equal;
%       % Are vertices 3 and 117 connected by an edge?
%       % (Bottom right-hand corner.)
%       isEdge(trep, 3, 117)  
%       isEdge(trep, 3, 164)  
%
%   Example 2:
%       % Direct query of a 3D Delaunay triangulation created using
%       % DelaunayTri. 
%       X = rand(10,3)
%       dt = DelaunayTri(X)
%       % Are vertices 2 and 7 connected by an edge?
%       isEdge(dt, 2, 7)  
%
%   See also TriRep, DelaunayTri. 

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.