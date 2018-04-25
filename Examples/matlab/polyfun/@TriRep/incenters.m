%incenters  Returns the incenters of the specified simplices
%
%   TriRep/incenters will be removed in a future release.
%   Use triangulation/incenter instead.
%
%   IC = incenters(TR, SI) Returns the coordinates of the incenter of each
%   specified simplex SI. A simplex is a triangle/tetrahedron or higher 
%   dimensional equivalent. SI is a column vector of simplex indices that 
%   index into the triangulation matrix TR.Triangulation. 
%   IC is an m-by-n matrix, where m is of length(SI), the number of specified 
%   simplices, and n is the dimension of the space where the triangulation 
%   resides. Each row IC(i,:) represents the coordinates of the incenter 
%   of simplex SI(i). If SI is not specified the incenter information for the
%   entire triangulation is returned, where the incenter associated with 
%   simplex i is the i'th row of IC.
%
%   [IC RIC] = incenters(TR, SI) returns in addition, the corresponding
%   radius of the inscribed circle/sphere. RIC is a vector of length
%   length(SI), the number of specified simplices.
%
%   Example 1: Load a 3D triangulation and use the TriRep to compute the 
%              incenters of the first five tetraherda.
%       load tetmesh
%       % This loads triangulation tet and vertex coordinates X
%       trep = TriRep(tet, X)
%       [ic ric] = incenters(trep, [1:5]')
%
%   Example 2: Direct query of a 2D triangulation created using DelaunayTri
%              Compute the incenters of the triangles and plot triangles
%              and incenters.
%       x = [0 1 1 0 0.5]';
%       y = [0 0 1 1 0.5]';
%       dt = DelaunayTri(x,y);
%       ic = incenters(dt);
%       % Display the triangles and incenters
%       triplot(dt);
%       axis equal;
%       axis([-0.2 1.2 -0.2 1.2]);
%       hold on; plot(ic(:,1),ic(:,2),'*r'); hold off;
%
%   See also TriRep, TriRep.circumcenters, DelaunayTri. 

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.