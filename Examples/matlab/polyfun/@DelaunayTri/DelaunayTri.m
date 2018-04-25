% DelaunayTri Creates a Delaunay triangulation from a set of points
%
%    DelaunayTri is not recommended. Use delaunayTriangulation instead.
%
%    DelaunayTri is used to create a Delaunay triangulation from a set of 
%    points in 2D/3D space. A 2D Delaunay triangulation of a set of points 
%    ensures that the circumcircle associated with each triangle contains 
%    no other point in its interior. This definition extends naturally to 
%    higher dimensions. With DelaunayTri you can incrementally modify the 
%    triangulation by adding or removing points. You can also perform 
%    topological and geometric queries, compute the Voronoi diagram, and 
%    convex hull. In 2D triangulations you can impose edge constraints 
%    between pairs of points.
%
%    DT = DelaunayTri() creates an empty Delaunay triangulation.
%
%    DT = DelaunayTri(X), DelaunayTri(X, Y), DelaunayTri(X, Y, Z) creates a 
%    Delaunay triangulation from a set of points. The points can be specified 
%    as an mpts-by-ndim matrix X, where mpts is the number of points and ndim
%    is the dimension of the space where the points reside, 2 <= ndim <= 3. 
%    Alternatively, the points can be specified as column vectors (X,Y) or 
%    (X,Y,Z) for 2D and 3D input.
%
%    DT = DelaunayTri(..., C) creates a constrained Delaunay triangulation. 
%    The edge constraints C are defined by an numc-by-2 matrix, numc being 
%    the number of constrained edges. Each row of C defines a constrained 
%    edge in terms of its endpoint indices into the point set X. This feature 
%    is only supported for 2D triangulations.
% 
%    Example: Compute the Delaunay triangulation of twenty random points 
%               located within a unit square.
%        x = rand(20,1);
%        y = rand(20,1);
%        dt = DelaunayTri(x,y)
%        triplot(dt);
%
%
% DelaunayTri methods:
%    convexHull         - Returns the convex hull
%    voronoiDiagram     - Returns the Voronoi diagram
%    nearestNeighbor    - Search for the point closest to the specified location
%    pointLocation      - Locate the simplex containing the specified location
%    inOutStatus        - Returns the in/out status of the triangles in a 2D constrained Delaunay
%
% DelaunayTri inherited methods:
%    DelaunayTri inherits all the methods of TriRep.
%    Refer to the help for TriRep for a list of these methods.
%
% DelaunayTri properties:
%    Constraints        - The imposed edge constraints - 2D only
%    X                  - The coordinates of the points in the triangulation
%    Triangulation      - The computed triangulation
%
% See also TriRep, triplot, trisurf, tetramesh, TriScatteredInterp.

%   Copyright 2008-2015 The MathWorks, Inc.
%   Built-in function.

%{
properties
    %Constraints - The imposed edge constraints - 2D only
    %    Constraints is a numc-by-2 matrix that defines the constrained edge 
    %    data in the triangulation, where numc is the number of constrained 
    %    edges. Each constrained edge is defined in terms of its endpoint 
    %    indices into X. 
    %
    %    The constraints can be specified when the triangulation is 
    %    constructed or can be imposed afterwards by directly editing the 
    %    constraints data.
    %
    %    Note: This feature is only supported for 2D triangulations. 
    %    The nearestNeighbor query is not supported for constrained 
    %    Delaunay triangulations.
    Constraints;    

    %X - The coordinates of the points in the triangulation
    %
    %    DelaunayTri/X will be removed in a future release.
    %    Use delaunayTriangulation/Points instead.
    %
    %    The dimension of X is mpts-by-ndim, where mpts is the number of points
    %    and ndim is the dimension of the space where the points reside. 
    %    If column vectors of X,Y or X,Y,Z coordinates are used to construct
    %    the triangulation, the data is consolidated into a single matrix X.
    X;
    
    %Triangulation - The computed triangulation
    %
    %    DelaunayTri/Triangulation will be removed in a future release.
    %    Use delaunayTriangulation/ConnectivityList instead.
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
