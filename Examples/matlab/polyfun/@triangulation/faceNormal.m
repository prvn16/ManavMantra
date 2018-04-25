%faceNormal  Triangulation face normal
%     FN = faceNormal(TR, TI) returns the unit normal vector to each of the
%     specified triangles TI, where TI is a column vector of triangle IDs.
%     These IDs correspond to the row number of the triangulation connectivity 
%     matrix TR.ConnectivityList.
%     FN is an m-by-3 matrix, where m is length(TI), the number of triangles
%     to be queried. Each row FN(i,:) represents the unit normal vector to
%     triangle TI(i). If TI is not specified the unit normal information for
%     the entire triangulation is returned, where the normal associated with
%     triangle i is the i'th row of FN.
%     Note: This query is only applicable to triangular surface meshes.
%
%   Example:
%	  % Triangulate a sample of random points on the surface of a sphere
%     % and use the triangulation to compute the normal to each triangle.
%     % Display the result using a quiver plot.
%       numpts = 100;
%       thetha = rand(numpts,1)*2*pi;
%       phi = rand(numpts,1)*pi;
%       x = cos(thetha).*sin(phi);
%       y = sin(thetha).*sin(phi);
%       z = cos(phi);
%       dt = delaunayTriangulation(x,y,z);
%       [tri Xb] = freeBoundary(dt);
%       tr = triangulation(tri, Xb);
%       P = incenter(tr);
%       fn = faceNormal(tr);
%       trisurf(tri,Xb(:,1),Xb(:,2),Xb(:,3),'FaceColor', 'cyan', 'faceAlpha', 0.8);
%       axis equal;
%       hold on;
%       quiver3(P(:,1),P(:,2),P(:,3),fn(:,1),fn(:,2),fn(:,3),0.5, 'color','r');
%       hold off;
%
%   See also triangulation, delaunayTriangulation.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.