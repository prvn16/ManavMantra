% delaunayTriangulation Delaunay triangulation in 2-D and 3-D
%    delaunayTriangulation is used to create a Delaunay triangulation from 
%    a set of points in 2D or 3D space. A 2D Delaunay triangulation of a set 
%    of points ensures that the circumcircle associated with each triangle 
%    contains no other point in its interior. This definition extends naturally 
%    to higher dimensions. With delaunayTriangulation you can incrementally 
%    modify the triangulation by adding or removing points. You can also 
%    perform topological and geometric queries, compute the Voronoi diagram, 
%    and convex hull. In 2D triangulations you can impose edge constraints
%    between pairs of points.
%
%    DT = delaunayTriangulation() creates an empty Delaunay triangulation.
%
%    DT = delaunayTriangulation(P), delaunayTriangulation(X, Y), 
%    delaunayTriangulation(X, Y, Z) creates a Delaunay triangulation from a 
%    set of points. The points can be specified as an mpts-by-ndim matrix P, 
%    where mpts is the number of points and 2 <= ndim <= 3.
%    Alternatively, the points can be specified as column vectors (X,Y) or
%    (X,Y,Z) for 2D and 3D input.
%
%    DT = delaunayTriangulation(..., C) creates a constrained Delaunay 
%    triangulation. The edge constraints C are defined by an numc-by-2 matrix, 
%    numc being the number of constrained edges. Each constrained edge is 
%    defined by a pair of vertex IDs, where a vertex ID corresponds to the 
%    row number into the point set. This feature is only supported for 2D 
%    triangulations.
%
%    Example: Compute the Delaunay triangulation of twenty random points
%               located within a unit square.
%        x = rand(20,1);
%        y = rand(20,1);
%        dt = delaunayTriangulation(x,y)
%        triplot(dt);
%
%
% delaunayTriangulation methods:
%    convexHull         - Convex hull
%    voronoiDiagram     - Voronoi diagram
%    isInterior         - Test if a triangle is in the interior of a 2-D constrained Delaunay triangulation
%
% delaunayTriangulation inherited methods:
%    delaunayTriangulation inherits all the methods of triangulation.
%    Refer to the help for triangulation for a list of these methods.
%
% delaunayTriangulation properties:
%    Constraints        - The imposed edge constraints - 2D only
%    Points             - The coordinates of the points in the triangulation
%    ConnectivityList   - The computed triangulation connectivity list
%
% See also delaunayTriangulationExample, triangulation, triplot, trisurf, tetramesh, scatteredInterpolant.

%   Copyright 2008-2014 The MathWorks, Inc.
%   Built-in function.

%{
properties
    %Constraints - The imposed edge constraints - 2D only
    % Constraints is a numc-by-2 matrix, numc being the number of constrained 
    % edges. Each constrained edge is defined by a pair of vertex IDs, where 
    % a vertex ID corresponds to the row number into Points. 
    %
    %    The constraints can be specified when the triangulation is
    %    constructed or can be imposed afterwards by directly editing the
    %    Constraints data.
    %
    %    Note: This feature is only supported for 2D triangulations.
    %    The nearestNeighbor query is not supported for constrained
    %    Delaunay triangulations.
    Constraints;

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

