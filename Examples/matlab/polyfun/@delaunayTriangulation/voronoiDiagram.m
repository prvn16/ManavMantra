% voronoiDiagram  Voronoi diagram
%   The Voronoi diagram of a set of points X decomposes the space around 
%   each point X(i) into a region of influence R{i}. Locations within the 
%   region R{i} are closer to point i than any other point in X. The region 
%   of influence is called the Voronoi region. The collection of all the 
%   Voronoi regions is the Voronoi diagram.
%
%   [V, R] = voronoiDiagram(DT)  returns the vertices V and regions R of
%   the Voronoi diagram of the points DT.Points. The region R{i} is a cell array
%   of indices into V that represents the Voronoi vertices bounding the
%   region. V is a numv-by-ndim matrix representing the coordinates of the
%   Voronoi vertices, where numv is the number of vertices and 2 <= ndim <= 3.
%   R is a vector cell array of length(DT.Points), representing the Voronoi 
%   cell associated with each point. Hence, the Voronoi region associated 
%   with the i'th point, DT.Points(i,:), is R{i}.
%
%   For 2-D, vertices in R{i} are listed in adjacent order, i.e. connecting
%   them will generate a closed polygon (Voronoi diagram). For 3-D
%   the vertices in R{i} are listed in ascending order.
%
%   The Infinite Vertex
%   The Voronoi regions associated with points that lie on the convex hull
%   of DT.Points are unbounded. Bounding edges of these regions radiate to
%   infinity. The vertex at infinity is represented by the first vertex in V.
%
%    Example: Compute the Voronoi Diagram of a set of points
%        X = [ 0.5    0
%              0      0.5
%             -0.5   -0.5
%             -0.2   -0.1
%             -0.1    0.1
%              0.1   -0.1
%              0.1    0.1 ]
%        dt = delaunayTriangulation(X)
%        [V,R] = voronoiDiagram(dt)
%
%    See also delaunayTriangulation, voronoi

% Copyright 2012 The MathWorks, Inc.
