%baryToCart Converts the coordinates of a point from barycentric to cartesian
%   
%   TriRep/baryTocart will be removed in a future release.
%   Use triangulation/barycentricToCartesian instead.
%
%   XC = baryToCart(TR, SI, B) Returns the cartesian coordinates XC of each 
%   point in B that represents the barycentric coordinates with respect to 
%   its associated simplex SI. A simplex is a triangle/tetrahedron or higher 
%   dimensional equivalent. SI is a column vector of simplex indices that 
%   index into the triangulation matrix TR.Triangulation. 
%   B is a matrix that represents the barycentric coordinates of the points 
%   to convert with respect to the simplices SI. B is of size m-by-k, 
%   where m is of length(SI), the number of points to convert, and k
%   is the number of vertices per simplex.
%   
%   XC is a matrix that represents the cartesian coordinates of the converted 
%   points. XC is of size m-by-n, where n is the dimension of the space 
%   where the triangulation resides. That is, the cartesian coordinates of 
%   the point B(j) with respect to simplex SI(j) is XC(j). 
%
%   Example 1: Compute the Delaunay triangulation of a set of points.
%              Compute the barycentric coordinates of the incenters.
%              "Stretch" the triangulation and compute the mapped locations
%              of the incenters on the deformed triangulation.
%              
%       x = [0 4 8 12 0 4 8 12]';
%       y = [0 0 0 0 8 8 8 8]';
%       dt = DelaunayTri(x,y)
%       cc = incenters(dt);
%       tri = dt(:,:);
%       subplot(1,2,1);
%       triplot(dt); hold on;
%       plot(cc(:,1), cc(:,2), '*r'); hold off;
%       axis equal;
%       title(sprintf('Original triangulation and reference points.\n'));
%       b = cartToBary(dt,[1:length(tri)]',cc);
%       % Create a representation of the stretched triangulation
%       y = [0 0 0 0 16 16 16 16]';
%       tr = TriRep(tri,x,y)
%       xc = baryToCart(tr, [1:length(tri)]', b);
%       subplot(1,2,2);
%       triplot(tr); hold on;
%       plot(xc(:,1), xc(:,2), '*r'); hold off;
%       axis equal;
%       title(sprintf('Deformed triangulation and mapped\n locations of the reference points.\n'));
%
%
%
%   See also TriRep, TriRep.cartToBary, DelaunayTri, DelaunayTri.pointLocation.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.