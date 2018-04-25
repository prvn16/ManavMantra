%vertexNormal  Triangulation vertex normal
%   This query is only applicable to triangular surface meshes.
%   VN = vertexNormal(TR, VI) Returns the unit normal vector to each of the 
%   specified vertices VI, where VI is a column vector of indices into
%   the array of points TR.Points. VN is an m-by-3 matrix, where m is 
%   length(VI), the number of vertices to be queried. Each row VN(i,:) 
%   represents the unit normal vector at the vertex VI(i). This is the 
%   average unit normal of the faces attached to vertex VI(i). If VI is not 
%   specified the unit normal information for all vertices is returned, 
%   where the normal associated with vertex i is the i'th row of VN.
%
%   Example:
%      % Create a triangulation representing the surface of a cube.
%      % Use the triangulation to compute the normal to each vertex.
%      % Display the result using a quiver plot.
%      [X, Y, Z] = meshgrid(1:4);
%      X = X(:);
%      Y = Y(:);
%      Z = Z(:);
%      dt = delaunayTriangulation(X,Y,Z);
%      [Tfb, Xfb] = freeBoundary(dt);
%      tr = triangulation(Tfb,Xfb);
%      vn = vertexNormal(tr);
%      trisurf(tr,'FaceColor', 'cyan');
%      axis equal
%      hold on
%      quiver3(Xfb(:,1),Xfb(:,2),Xfb(:,3),vn(:,1),vn(:,2),vn(:,3),0.5, 'color','r');
%      hold off
%
%   See also triangulation, delaunayTriangulation.

%   Copyright 2012 The MathWorks, Inc.
%   Built-in function.