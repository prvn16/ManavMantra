%cartesianToBarycentric Converts the coordinates of a point from Cartesian to Barycentric
% PB = cartesianToBarycentric(TR, TI, PC) converts the Cartesian coordinates
%     PC into Barycentric coordinates PB. Each row of PC represents the 
%     Cartesian coordinates of a point and TI is the index of the corresponding
%     triangle or tetrahedron to be used in the Barycentric computation.
%     TI is a column vector of triangle or tetrahedron IDs, corresponding 
%     to a row index into the triangulation connectivity matrix 
%     TR.ConnectivityList.
%
%     PB represents the Barycentric coordinates of the points PC with respect 
%     to TI. That is, the Barycentric coordinates of the point PC(j,:) with 
%     respect to TI(j) is PB(j,:). PB is a matrix of dimension m-by-k where 
%     k is the number of vertices per triangle/tetrahedron.
%
%   Example 1: Compute the Delaunay triangulation of a set of points.
%              Compute the Barycentric coordinates of the incenters.
%              "Stretch" the triangulation and compute the mapped locations
%              of the incenters on the deformed triangulation.
%
%       x = [0 4 8 12 0 4 8 12]';
%       y = [0 0 0 0 8 8 8 8]';
%       dt = delaunayTriangulation(x,y)
%       cc = incenter(dt);
%       tri = dt(:,:);
%       subplot(1,2,1);
%       triplot(dt); hold on;
%       plot(cc(:,1), cc(:,2), '*r'); hold off;
%       axis equal;
%       title(sprintf('Original triangulation and reference points.\n'));
%       b = cartesianToBarycentric(dt,[1:length(tri)]',cc);
%       % Create a representation of the stretched triangulation
%       y = [0 0 0 0 16 16 16 16]';
%       tr = triangulation(tri,x,y)
%       xc = barycentricToCartesian(tr, [1:length(tri)]', b);
%       subplot(1,2,2);
%       triplot(tr); hold on;
%       plot(xc(:,1), xc(:,2), '*r'); hold off;
%       axis equal;
%       title(sprintf('Deformed triangulation and mapped\n locations of the reference points.\n'));
%
%   See also triangulation, triangulation.barycentricToCartesian, delaunayTriangulation.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.