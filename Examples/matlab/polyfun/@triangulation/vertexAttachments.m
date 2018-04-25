%vertexAttachments  Triangles or tetrahedra attached to a vertex 
% TI = vertexAttachments(TR, VI) returns the triangles or tetrahedra attached 
%     to the specified vertices VI. TI is a vector cell array where each cell 
%     contains triangle or tetrahedron IDs corresponding to the row numbers 
%     of the triangulation connectivity matrix TR.ConnectivityList. TI is a 
%     cell array because the number of triangles/tetrahedra associated with 
%     each vertex can vary. 
%     VI is a column vectors of vertex IDs, where a vertex ID corresponds 
%     to the row number into TR.Points. If VI is not specified the 
%     vertex-triangle/tetrahedron information for the entire triangulation 
%     is returned.
%  
%     In relation to 2D triangulations, if the triangulation has a consistent 
%     orientation the triangles in each cell will be ordered consistently 
%     around each vertex.
%
%   Example 1: Load a 2D triangulation and use the triangulation to compute the 
%              vertex-to-ttriangle relations.
%       load trimesh2d
%       % This loads triangulation tet and vertex coordinates x and y
%       trep = triangulation(tri, x, y);
%       Tv = vertexAttachments(trep, 1)
%       % The indices of the tetrahedra attached to the first vertex
%       Tv{:}
%
%   Example 2: Direct query of a 2D triangulation created using delaunayTriangulation
%       x = rand(20,1);
%       y = rand(20,1);
%       dt = delaunayTriangulation(x,y);
%       t = vertexAttachments(dt,5);
%       % Plot the triangles attached to vertex 5, in red.
%       triplot(dt);
%       hold on; triplot(dt(t{:},:),x,y,'Color','r'); hold off;
%
%   See also triangulation, delaunayTriangulation.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.
