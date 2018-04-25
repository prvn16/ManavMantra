%barycentricToCartesian Converts the coordinates of a point from Barycentric to Cartesian
%     PC = barycentricToCartesian(TR, TI, PB) converts Barycentric coordinates
%     PB into Cartesian coordinates PC. Each row of PB represents the Barycentric 
%     coordinates of a point with respect to its associated triangle or 
%     tetrahedron TI. TI is a column vector of triangle or tetrahedron IDs,
%     corresponding to a row index into the triangulation connectivity matrix 
%     TR.ConnectivityList. PB is a matrix that represents the Barycentric 
%     coordinates of the points with respect TI. PB is of size m-by-k, where 
%     m is of length(TI), the number of points to convert, and k is the number of 
%     vertices per triangle/tetrahedron.
%
%     PC represents the Cartesian coordinates of the converted points. 
%     PC is of size m-by-n, where n is the spatial dimension 2<=n<=3.
%     That is, the Cartesian coordinates of the point PB(j,:) with respect 
%     to triangle/tetrahedron TI(j) is PC(j,:).
%
% Example 1: Compute the Delaunay triangulation of a set of points.
%            Compute the barycentric coordinates of the incenters.
%            "Stretch" the triangulation and compute the mapped locations
%            of the incenters on the deformed triangulation.
%
%     x = [0 4 8 12 0 4 8 12]';
%     y = [0 0 0 0 8 8 8 8]';
%     dt = delaunayTriangulation(x,y)
%     cc = incenter(dt);
%     tri = dt(:,:);
%     subplot(1,2,1);
%     triplot(dt); hold on;
%     plot(cc(:,1), cc(:,2), '*r'); hold off;
%     axis equal;
%     title(sprintf('Original triangulation and reference points.\n'));
%     b = cartesianToBarycentric(dt,[1:length(tri)]',cc);
%     % Create a representation of the stretched triangulation
%     y = [0 0 0 0 16 16 16 16]';
%     tr = triangulation(tri,x,y)
%     xc = barycentricToCartesian(tr, [1:length(tri)]', b);
%     subplot(1,2,2);
%     triplot(tr); hold on;
%     plot(xc(:,1), xc(:,2), '*r'); hold off;
%     axis equal;
%     title(sprintf('Deformed triangulation and mapped\n locations of the reference points.\n'));
%
%   See also triangulation, triangulation.cartesianToBarycentric, delaunayTriangulation.

%   Copyright 2012 The MathWorks, Inc.
%   Built-in function.