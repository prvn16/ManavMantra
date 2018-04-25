%circumcenters  Returns the circumcenters of the specified simplices
%
%   TriRep/circumcenters will be removed in a future release.
%   Use triangulation/circumcenter instead.
%
%   CC = circumcenters(TR, SI) Returns the coordinates of the circumcenter
%   of each specified simplex SI. A simplex is a triangle/tetrahedron or
%   higher dimensional equivalent. SI is a column vector of simplex indices
%   that index into the triangulation matrix TR.Triangulation. 
%   CC is an m-by-n matrix, where m is of length(SI), the number of specified 
%   simplices, and n is the dimension of the space where the triangulation 
%   resides. Each row CC(i,:) represents the coordinates of the circumcenter 
%   of simplex SI(i). If SI is not specified the circumcenter information for
%   the entire triangulation is returned, where the circumcenter associated
%   with simplex i is the i'th row of CC.
%
%   [CC RCC] = circumcenters(TR, SI) returns in addition, the corresponding
%   radius of the circumscribed circle/sphere. RCC is a vector of length
%   length(SI), the number of specified simplices.
%
%   Example 1: Load a 2D triangulation and use the TriRep to compute the 
%              circumcenters.
%       load trimesh2d
%       % This loads triangulation tri and vertex coordinates  x, y
%       trep = TriRep(tri, x,y)
%       cc = circumcenters(trep);
%       triplot(trep);
%       axis([-50 350 -50 350]);
%       axis equal;
%       hold on; plot(cc(:,1),cc(:,2),'*r'); hold off;
%       % The circumcenters represent points on the 
%       % medial axis of the polygon.
%
%   Example 2: Direct query of a 3D triangulation created using DelaunayTri
%	           Compute the circumcenters of the first five tetrahedra.
%       X = rand(10,3);
%       dt = DelaunayTri(X);
%       [cc rcc] = circumcenters(dt, [1:5]')
%
%   See also TriRep, TriRep.incenters, DelaunayTri. 

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.