%vertexAttachments  Returns the simplices attached to the specified vertices
%  
%   TriRep/vertexAttachments will be removed in a future release.
%   Use triangulation/vertexAttachments instead.
%
%   SI = vertexAttachments(TR, VI) Returns the vertex-to-simplex information 
%   for the specified vertices VI. A simplex is a triangle/tetrahedron or
%   higher dimensional equivalent. VI is a column vector of indices into
%   the array of points representing the vertex coordinates, TR.X.
%   The simplices associated with vertex i are the i'th entry in the cell 
%   array. If VI is not specified the vertex-simplex information for the 
%   entire triangulation is returned, where the simplices associated with 
%   vertex i are in the i'th entry in the cell array SI. A cell array is 
%   used to store the information because the number of simplices associated 
%   with each vertex can vary. 
%
%   In relation to 2D triangulations, if the triangulation has a consistent 
%   orientation the triangles in each cell will be ordered consistently 
%   around each vertex.
%
%   Example 1: Load a 2D triangulation and use the TriRep to compute the 
%              vertex-to-ttriangle relations.
%       load trimesh2d
%       % This loads triangulation tet and vertex coordinates X
%       trep = TriRep(tri, x, y);
%       Tv = vertexAttachments(trep, 1)
%       % The indices of the tetrahedra attached to the first vertex
%       Tv{:}
%
%   Example 2: Direct query of a 2D triangulation created using DelaunayTri
%       x = rand(20,1);
%       y = rand(20,1);
%       dt = DelaunayTri(x,y);
%       t = vertexAttachments(dt,5);
%       % Plot the triangles attached to vertex 5, in red.
%       triplot(dt);
%       hold on; triplot(dt(t{:},:),x,y,'Color','r'); hold off;
%
%   See also TriRep, DelaunayTri.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.
