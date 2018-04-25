% nearestNeighbor  Nearest point on the alpha shape boundary
%    PI = nearestNeighbor(SHP,QX,QY), for a 2-D alpha shape, returns the
%    indices of the points on the boundary of SHP that are nearest to the
%    query points (QX,QY). The arrays QX and QY specify the coordinates of
%    the query points. PI is an array of point IDs of size equal to QX and
%    QY. A point ID corresponds to the row number in SHP.Points.
%    
%    PI = nearestNeighbor(SHP,QX,QY,QZ), for a 3-D alpha shape, returns the
%    indices of the points on the boundary of SHP that are nearest to the
%    query points (QX,QY,QZ). The arrays QX, QY, and QZ specify the
%    coordinates of the query points. PI is an array of point IDs of size
%    equal to QX, QY, and QZ. A point ID corresponds to the row number in
%    SHP.Points.
%
%    PI = nearestNeighbor(SHP,QP) returns the indices of the points
%    on the boundary of SHP that are nearest to the query points QP.
%    The matrix QP has M rows representing M query points and 2 or 3
%    columns. PI is a column vector of point IDs of length M. A point ID
%    corresponds to the row number in SHP.Points.
%
%    PI = nearestNeighbor(...,REGIONID) returns the indices of the nearest
%    points that lie on the boundary of the region specified by the scalar
%    REGIONID where 1 <= REGIONID <= numRegions(SHP).
%
%    [PI,D] = nearestNeighbor(...) also returns the Euclidean distances D
%    between the query points and their nearest neighbors. D has the same
%    size as PI.
%
%    Example: Compute the alpha shape of a set of 2-D points. For a given
%             query point, compute the nearest alpha shape boundary point.
%       % Create a set of points (x,y) and an alphaShape.
%       th = (pi/12:pi/12:2*pi)';
%       x1 = [reshape(cos(th)*(1:5), numel(cos(th)*(1:5)),1); 0];
%       y1 = [reshape(sin(th)*(1:5), numel(sin(th)*(1:5)),1); 0];
%       x = [x1; x1+15;];
%       y = [y1; y1];
%       shp = alphaShape(x,y,1)
%       % Compute the nearest neighbor of qp.
%       qp = [6 3]
%       pi = nearestNeighbor(shp, qp)
%       % Plot the alpha shape
%       plot(shp,'EdgeColor','none')
%       hold on
%       % Plot the alpha shape boundary points.
%       [~, bp] = shp.boundaryFacets();
%       plot(bp(:,1), bp(:,2),'k.')
%       % Plot the query point as a blue circle and the nearest alpha shape
%       % boundary point as a red square. Also draw a line between them.
%       plot([qp(1); shp.Points(pi,1)], [qp(2); shp.Points(pi,2)], '-k')
%       plot(qp(1), qp(2), 'bo')
%       plot(shp.Points(pi,1), shp.Points(pi,2),'rs')
%       hold off
%
%    See also alphaShape, alphaShape.plot, alphaShape.inShape, 
%             triangulation.nearestNeighbor

% Copyright 2013-2014 The MathWorks, Inc.