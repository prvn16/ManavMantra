% size    Returns the size of the Triangulation matrix
%    triangulation overrides the MATLAB size function to provide size
%    information for the triangulation connectivity matrix. The matrix is 
%    of size mtri-by-nv, where mtri is the number of triangles/tetrahedra 
%    and 3 <= nv <= 4 is the number of vertices.

%    Copyright 2012 The MathWorks, Inc.