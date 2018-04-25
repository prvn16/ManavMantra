%isConnected  Test if a pair of vertices is connected by an edge
%
%  TF = isConnected(TR, V1, V2) returns an array of 1/0 (true/false) flags,
%     where each entry TF(i) is true if V1(i), V2(i) is connected by an edge in the
%     triangulation. V1, V2 are column vectors representing the indices of the
%     vertices in the triangulation.
%   TF = isConnected(TR, EDGE) 	Specifies the edge start and end indices in
%     matrix format where EDGE is of size n-by-2, n being the number of
%     query edges.
%
%   Example 1:
%       % Load a 2D triangulation and use the triangulation to query the
%       % presence of an edge between a pair of points.
%       load trimesh2d
%       % This loads triangulation tri and vertex coordinates x, y
%       trep = triangulation(tri, x,y);
%       triplot(trep);
%       vxlabels = arrayfun(@(n) {sprintf('P%d', n)}, [3 117 164]');
%       Hpl = text(x([3 117 164]), y([3 117 164]), vxlabels, 'FontWeight', ...
%                    'bold', 'HorizontalAlignment',...
%                   'center', 'BackgroundColor', 'none');
%       axis([-50 350 -50 350]);
%       axis equal;
%       % Are vertices 3 and 117 connected by an edge?
%       % (Bottom right-hand corner.)
%       isConnected(trep, 3, 117)
%       isConnected(trep, 3, 164)
%
%   Example 2:
%       % Direct query of a 3D Delaunay triangulation created using
%       % delaunayTriangulation.
%       Points = rand(10,3)
%       dt = delaunayTriangulation(Points)
%       % Are vertices 2 and 7 connected by an edge?
%       isConnected(dt, 2, 7)
%
%   See also triangulation, delaunayTriangulation.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.