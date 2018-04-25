% pointLocation  Triangle or tetrahedron containing specified point
% TI = pointLocation(T, QP)  returns the index of the triangle/tetrahedron
%      enclosing the query point QP. The matrix QP contains the coordinates
%      of the query points. QP is a mpts-by-ndim matrix where mpts is the 
%      number of query points and 2 <= ndim <= 3.
%      TI is a column vector of triangle or tetrahedron IDs corresponding to the 
%      row numbers of the triangulation connectivity matrix T.ConnectivityList. 
%      The triangle/tetrahedron enclosing the point QP(k,:) is TI(k). 
%      Returns NaN for points not located in a triangle or tetrahedron of T.
% 
%      TI = pointLocation(T, QX,QY) and TI = pointLocation (T, QX,QY,QZ)
%      allow the query points to be specified in alternative column vector 
%      format when working in 2D and 3D.
% 
%      [TI, BC] = pointLocation(T,...) returns, in addition, the Barycentric
%      coordinates BC. BC is a mpts-by-ndim matrix, each row BC(i,:) represents
%      the Barycentric coordinates of QP(i,:) with respect to the enclosing TI(i).
%
%    Example 1:
%        % Point Location in 2D
%        T = triangulation([1 2 4; 1 4 3; 2 4 5],[0 0; 2 0; 0 1; 1 1; 2 1]);
%        % Find the triangle that contains the following query point
%        QP = [1, 0.5];
%        triplot(T,'-b*'), hold on
%        plot(QP(:,1),QP(:,2),'ro')
%        % The query point QP is located in a triangle with index TI = 1
%        TI = pointLocation(T, QP)
%
%    Example 2:
%        % Point Location in 3D plus barycentric coordinate evaluation
%        % for a Delaunay triangulation
%        x = rand(10,1); y = rand(10,1); z = rand(10,1);
%        DT = delaunayTriangulation(x,y,z);
%        % Find the tetrahedra that contain the following query points
%        QP = [0.25 0.25 0.25; 0.5 0.5 0.5]
%        [TI, BC] = pointLocation(DT, QP)
%
%    See also triangulation, triangulation.nearestNeighbor, delaunayTriangulation.

%    Copyright 2012-2014 The MathWorks, Inc.
%    Built-in function.