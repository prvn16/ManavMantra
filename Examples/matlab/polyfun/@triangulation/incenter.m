%incenter  Incenter or triangle or tetrahedron
% IC = incenter(TR, TI) returns the coordinates of the incenter of each
%      triangle or tetrahedron in TI.
%     TI is a column vector of triangle or tetrahedron IDs corresponding to
%     the row numbers of the triangulation connectivity matrix TR.ConnectivityList.
%     IC is an m-by-n matrix, where m is of length(TI), the number of specified
%     triangles/tetrahedra, and n is the spatial dimension 2 <= n <= 3.
%     Each row IC(i,:) represents the coordinates of the incenter
%     of TI(i). If TI is not specified the incenter information for the
%     entire triangulation is returned, where the incenter associated with
%     triangles/tetrahedra i is the i'th row of IC.
%
%     [IC RIC] = incenter(TR, TI) returns in addition, the corresponding
%     radius of the inscribed circle/sphere. RIC is a vector of length
%     length(TI), the number of specified triangles/tetrahedra.
%
%   Example 1: Load a 3D triangulation and use the triangulation to compute the
%              incenters of the first five tetraherda.
%       load tetmesh
%       % This loads triangulation tet and vertex coordinates X
%       trep = triangulation(tet, X)
%       [ic ric] = incenter(trep, [1:5]')
%
%   Example 2: Direct query of a 2D triangulation created using delaunayTriangulation
%              Compute the incenters of the triangles and plot triangles
%              and incenters.
%       x = [0 1 1 0 0.5]';
%       y = [0 0 1 1 0.5]';
%       dt = delaunayTriangulation(x,y);
%       ic = incenter(dt);
%       % Display the triangles and incenters
%       triplot(dt);
%       axis equal;
%       axis([-0.2 1.2 -0.2 1.2]);
%       hold on; plot(ic(:,1),ic(:,2),'*r'); hold off;
%
%   See also triangulation, triangulation.circumcenter, delaunayTriangulation.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.