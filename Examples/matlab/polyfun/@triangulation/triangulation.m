%triangulation     Triangulation in 2-D or 3-D
%   triangulation supports topological and geometric queries for triangulations 
%   in 2D and 3D space. For example, you can query triangles attached to a 
%   vertex, triangle neighbor information, circumcenters, etc. 
%   You can create a triangulation directly using existing triangulation data
%   in matrix format. Alternatively, you can create a delaunayTriangulation, 
%   which provides access to the triangulation functions.
%
%   TR = triangulation(TRI, X, Y) creates a 2D triangulation from the 
%   triangulation connectivity matrix TRI and the points (X, Y). TRI is an 
%   m-by-3 matrix where m is the number of triangles.  Each row of TRI is a 
%   triangle defined by vertex IDs - the row numbers of the points (X, Y).
%   The point coordinates (X, Y) are column vectors representing the points 
%   in the triangulation.
%
%   TR = triangulation(TRI, X, Y, Z) creates a 3D triangulation from the 
%   triangulation connectivity matrix TRI and the points (X, Y, Z). TRI is 
%   an m-by-3 or m-by-4 matrix that represents m triangles or tetrahedra
%   that have 3 or 4 vertices respectively.  Each row of TRI is a triangle 
%   or tetrahedron defined by vertex IDs - the row numbers of the 
%   points (X, Y, Z). The point coordinates (X, Y, Z) are column vectors 
%   representing the points in the triangulation.
%
%   TR = triangulation(TRI, P) creates a triangulation from the triangulation
%   connectivity matrix TRI and the points P. TRI is an m-by-3 or m-by-4 
%   matrix that represents m triangles or tetrahedra that have 3 or 4 vertices 
%   respectively. Each row of TRI is a triangle or tetrahedron defined by 
%   vertex IDs - the row numbers of the points P. P is a mpts-by-ndim matrix 
%   where mpts is the number of points and ndim is the number of dimensions, 
%   2 <= ndim <= 3.
%
%
%   Example 1:
%       % Load a 2D triangulation in matrix format and use the triangulation 
%       % to query the free boundary edges.
%       load trimesh2d
%       % This loads triangulation tri and vertex coordinates x, y
%       trep = triangulation(tri, x,y);
%       fe = freeBoundary(trep)';
%       triplot(trep);
%       % Add the free edges in red
%       hold on; plot(x(fe), y(fe), 'r','LineWidth',2); hold off;
%       axis([-50 350 -50 350]);
%       axis equal;
%
%   Example 2:
%       % Load a 3D tetrahedral triangulation in matrix format and use the 
%       % triangulation to compute the free boundary.
%       load tetmesh
%       % This loads triangulation tet and vertex coordinates X
%       trep = triangulation(tet, X);
%       [tri, Xb] = freeBoundary(trep);
%       %Plot the surface mesh
%       trisurf(tri, Xb(:,1), Xb(:,2), Xb(:,3), 'FaceColor', 'cyan', 'FaceAlpha', 0.8);
%
%   Example 3:
%       % Direct query of a 3D Delaunay triangulation created using
%       % delaunayTriangulation. Compute the free boundary as in Example 2
%       Points = rand(50,3);
%       dt = delaunayTriangulation(Points);
%       [tri, Xb] = freeBoundary(dt);
%       %Plot the surface mesh
%       trisurf(tri, Xb(:,1), Xb(:,2), Xb(:,3), 'FaceColor', 'cyan','FaceAlpha', 0.8);
%
%
%   triangulation methods:
%        barycentricToCartesian - Converts the coordinates of a point from Barycentric to Cartesian
%        cartesianToBarycentric - Converts the coordinates of a point from Cartesian to Barycentric
%        circumcenter           - Circumcenter of triangle or tetrahedron
%        edgeAttachments        - Triangles or tetrahedra attached to an edge
%        edges                  - Triangulation edges
%        faceNormal             - Triangulation face normal
%        featureEdges           - Triangulation sharp edges
%        freeBoundary           - Triangulation facets referenced by only one triangle or tetrahedron
%        incenter               - Incenter of triangle or tetrahedron
%        isConnected            - Test if a pair of vertices is connected by an edge
%        neighbors              - Neighbors to a triangle or tetrahedron
%        vertexAttachments      - Triangles or tetrahedra attached to a vertex
%        vertexNormal           - Triangulation vertex normal
%        size                   - Size of the triangulation ConnectivityList
%        nearestNeighbor        - Vertex closest to a specified point
%        pointLocation          - Triangle or tetrahedron containing a specified point
%
%    triangulation properties:
%        Points            - The coordinates of the points in the triangulation
%        ConnectivityList  - The triangulation connectivity list
%
%   See also delaunayTriangulation.

%   Copyright 2008-2014 The MathWorks, Inc.
%   Built-in function.

%{
properties
    %Points - The coordinates of the points in the triangulation
    %    The size of Points is mpts-by-ndim, where mpts is the number of
    %    points and ndim is the number of dimensions, 2 <= ndim <= 3.
    %    If column vectors of X,Y or X,Y,Z coordinates are used, the data 
    %    is consolidated into a single matrix.
    Points;
    
    %ConnectivityList - The triangulation connectivity list
    %    ConnectivityList is matrix is of size mtri-by-nv, where mtri is 
    %    the number of triangles or tetrahedra and nv is the number of 
    %    vertices - 3 or 4. Each row specifies a triangle or tetrahedron 
    %    defined by vertex IDs - the row numbers of the Points matrix.
    ConnectivityList;
end
%}

%    Copyright 2012-2014 The MathWorks, Inc.
