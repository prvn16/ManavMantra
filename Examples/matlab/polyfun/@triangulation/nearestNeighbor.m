% nearestNeighbor  Vertex closest to a specified point
% VI = nearestNeighbor(T, QP)  returns the index of the triangulation vertex
%      nearest to the query point QP. The matrix QP contains the coordinates of
%      the query points. QP is a mpts-by-ndim matrix where mpts is the number of
%      query points and 2 <= ndim <= 3. VI is a column vector of vertex IDs of
%      length mpts, where a vertex ID corresponds to the row number into T.Points.
% 
%      VI = nearestNeighbor(T, QX,QY) and VI = nearestNeighbor(T, QX,QY,QZ)
%      allow the query points to be specified in alternative column vector
%      format in 2D and 3D.
% 
%      [VI, D] = nearestNeighbor(T,...)  returns, in addition, the corresponding
%      Euclidean distances D between the query points and their nearest
%      neighbors. D is a column vector of length mpts.
%
%      Note: nearestNeighbor is not supported for 2D Delaunay triangulations that
%            have constrained edges.
%
%    Example 1:
%        % Nearest Neighbor in 2D plus distance evaluation
%        T = triangulation([1 2 4; 1 4 3; 2 4 5],[0 0; 2 0; 0 1; 1 1; 2 1]);
%        % Find the vertex closest to the following query point
%        QP = [1, 0.5];
%        triplot(T,'-b*'), hold on
%        plot(QP(:,1),QP(:,2),'ro')
%        % The nearest vertex has index VI = 4 and is located at a distance 
%        % of D = 0.5 from the query point QP
%        [VI, D] = nearestNeighbor(T, QP)
%
%    Example 2:
%        % Nearest Neighbor in 3D plus distance evaluation
%        % for a Delaunay triangulation
%        x = rand(10,1); y = rand(10,1); z = rand(10,1);
%        DT = delaunayTriangulation(x,y,z);
%        % Find the vertices closest to the following query points
%        QP = [0.25 0.25 0.25; 0.5 0.5 0.5]
%        [VI, D] = nearestNeighbor(DT, QP)
%
%    See also triangulation, triangulation.pointLocation, delaunayTriangulation.

%    Copyright 2012-2014 The MathWorks, Inc.
%    Built-in function.