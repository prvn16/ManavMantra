%featureEdges  Triangulation sharp edges
%
% This query is only applicable to triangular surface meshes.
%     FE = featureEdges(TR, FILTERANGLE) returns a matrix FE that represents
%     the edges of the triangulation whose adjacent triangles have a dihedral
%     angle that deviates from PI by an angle greater than FILTERANGLE. This
%     method is typically used to extract the sharp edges in the surface triangulation
%     for the purpose of display. Edges that are shared by only one triangle,
%     and edges that are shared by more than two triangles are considered to
%     be feature edges by default.
%     FE is of size m-by-2 where m is the number of feature edges in the triangulation.
%     The vertices of the edges index into the array of points TR.Points.
%
%   Example 1:
%       % Create a surface triangulation and extract the feature edges.
%       x = [0 0 0 0 0 3 3 3 3 3 3 6 6 6 6 6 9 9 9 9 9 9]';
%       y = [0 2 4 6 8 0 1 3 5 7 8 0 2 4 6 8 0 1 3 5 7 8]';
%       dt = delaunayTriangulation(x,y);
%       tri = dt(:,:);
%       % Elevate the 2D mesh to create a surface
%       z = [0 0 0 0 0 2 2 2 2 2 2 0 0 0 0 0 0 0 0 0 0 0]';
%       subplot(1,2,1);
%       trisurf(tri,x,y,z, 'FaceColor', 'cyan'); axis equal;
%       title(sprintf('TRISURF display of surface mesh\n showing mesh edges\n'));
%       % Compute the feature edges using a filter angle of pi/4
%       tr = triangulation(tri, x,y,z);
%       fe = featureEdges(tr,pi/6)';
%       subplot(1,2,2);
%       trisurf(tr, 'FaceColor', 'cyan', 'EdgeColor','none', ...
%       'FaceAlpha', 0.8); axis equal;
%       % Add the feature edges
%       hold on; plot3(x(fe), y(fe), z(fe), 'k', 'LineWidth',1.5); hold off;
%       title(sprintf('TRISURF display of surface mesh\n suppressing mesh edges\nand showing feature edges'));
%
%   Example 2:
%       % Load a 3D triangulation and use the triangulation to compute the
%       % featureEdges and plot the result.
%       load trimesh3d.mat
%       % Construct a triangulation that represents the triangulation
%       tr = triangulation(tri, x,y,z);
%       %  Extract the feature edges.
%       fe = tr.featureEdges(pi/4);
%       fe = fe';
%       trisurf(tr,'FaceColor', 'cyan', 'EdgeColor', 'none');
%       axis equal
%       hold on
%       plot3(x(fe), y(fe), z(fe), '-k', 'LineWidth', 1.35);
%
%   See also triangulation, delaunayTriangulation.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.


