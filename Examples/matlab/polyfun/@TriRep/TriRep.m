%TriRep     A Triangulation Representation 
%
%   TriRep is not recommended. Use triangulation instead.
%
%   TriRep is a triangulation representation that provides topological and 
%   geometric queries for triangulations in 2D and 3D space. For example, 
%   for triangular meshes you can query triangles attached to a vertex, 
%   triangles that share an edge, neighbor information, circumcenters, etc. 
%   You can create a TriRep directly using existing triangulation data. 
%   Alternatively, you can create a Delaunay triangulation, via DelaunayTri, 
%   which provides access to the TriRep functionality.
%
%   TR = TriRep(TRI, X, Y) creates a 2D TriRep from the triangulation matrix 
%   TRI and the vertex coordinates (X, Y). TRI is an m-by-3 matrix that 
%   defines the triangulation in face-vertex format, where m is the 
%   number of triangles. Each row of TRI is a triangle defined by indices 
%   into the column vector of vertex coordinates (X, Y). 
%
%   TR = TriRep(TRI, X, Y, Z) creates a 3D TriRep from the triangulation 
%   matrix TRI and the vertex coordinates (X, Y, Z). TRI is an m-by-3 or 
%   m-by-4 matrix that defines the triangulation in simplex-vertex
%   format, where m is the number of simplices; triangles or tetrahedra 
%   in this case. Each row of TRI is a simplex defined by indices into the 
%   column vector of vertex coordinates (X, Y, Z). 
%
%   TR = TriRep(TRI, X) creates a TriRep from the triangulation matrix TRI
%   and the vertex coordinates X. TRI is an m-by-n matrix that defines the
%   triangulation in simplex-vertex format, where m is the number of
%   simplices and n is the number of vertices per simplex. Each row of TRI 
%   is a simplex defined by indices into the array of vertex coordinates X.
%   X is a mpts-by-ndim matrix where mpts is the number of points and ndim 
%   is the dimension of the space where the points reside, 2 <= ndim <= 3.
%
%
%   Example 1:
%       % Load a 2D triangulation and use the TriRep
%       % to build an array of the free boundary edges.
%       load trimesh2d
%       % This loads triangulation tri and vertex coordinates x, y
%       trep = TriRep(tri, x,y);
%       fe = freeBoundary(trep)';
%       triplot(trep);
%       % Add the free edges in red
%       hold on; plot(x(fe), y(fe), 'r','LineWidth',2); hold off;
%       axis([-50 350 -50 350]);
%       axis equal;
%
%   Example 2:
%       % Load a 3D tetrahedral triangulation and use the TriRep
%       % to compute the free boundary; the surface of the triangulation.
%       load tetmesh
%       % This loads triangulation tet and vertex coordinates X
%       trep = TriRep(tet, X);
%       [tri, Xb] = freeBoundary(trep);
%       %Plot the surface mesh
%       trisurf(tri, Xb(:,1), Xb(:,2), Xb(:,3), 'FaceColor', 'cyan', 'FaceAlpha', 0.8); 
%
%   Example 3:
%       % Direct query of a 3D Delaunay triangulation created using
%       % DelaunayTri. Compute the free boundary as in Example 2
%       X = rand(50,3);
%       dt = DelaunayTri(X);
%       [tri, Xb] = freeBoundary(dt);
%       %Plot the surface mesh
%       trisurf(tri, Xb(:,1), Xb(:,2), Xb(:,3), 'FaceColor', 'cyan','FaceAlpha', 0.8); 
%
%
%   TriRep methods:
%        baryToCart     - Converts the coordinates of a point from barycentric to cartesian
%        cartToBary     - Converts the coordinates of a point from cartesian to barycentric
%        circumcenters  - Returns the circumcenters of the specified simplices
%        edgeAttachments  - Returns the simplices attached to the specified edges
%        edges          - Returns the edges in the triangulation
%        faceNormals    - Returns the unit normals to the specified triangles
%        featureEdges   - Returns the sharp edges of a surface triangulation
%        freeBoundary   - Returns the facets referenced by only one simplex
%        incenters      - Returns the incenters of the specified simplices
%        isEdge         - Tests whether a pair of vertices are joined by an edge
%        neighbors      - Returns the simplex neighbor information
%        vertexAttachments  - Returns the simplices attached to the specified vertices
%        size               - Returns the size of the Triangulation matrix
%
%    TriRep properties:
%        X   - The coordinates of the points in the triangulation
%        Triangulation  - The triangulation data structure
%
%   See also DelaunayTri.

%   Copyright 2008-2015 The MathWorks, Inc
%   Built-in function.

%{
properties
    %X - The coordinates of the points in the triangulation
    %
    %    TriRep/X will be removed in a future release.
    %    Use triangulation/Points instead.
    %
    %    The dimension of X is mpts-by-ndim, where mpts is the number of 
    %    points and ndim is the dimension of the space where the points 
    %    reside 2 <= ndim <= 3.
    %    If column vectors of X,Y or X,Y,Z coordinates are used to construct
    %    the triangulation, the data is consolidated into a single matrix X.
    X;
    
    %Triangulation - The triangulation data structure
    %
    %    TriRep/Triangulation will be removed in a future release.
    %    Use triangulation/ConnectivityList instead.
    %
    %    Triangulation is a matrix representing the set of simplices (triangles
    %    or tetrahedra etc.) that make up the triangulation. The matrix is of 
    %    size mtri-by-nv, where mtri is the number of simplices and nv is the
    %    number of vertices per simplex. The triangulation is represented by 
    %    standard simplex-vertex format; each row specifies a simplex defined 
    %    by indices into X - the array of point coordinates.
    Triangulation;
end
%}

