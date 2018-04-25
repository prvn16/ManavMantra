% size    Returns the size of the Triangulation matrix
%    TriRep overrides the MATLAB size function to provide size 
%    information for the Triangulation matrix. The matrix is of size 
%    mtri-by-nv, where mtri is the number of simplices and nv is the 
%    number of vertices per simplex (triangle/tetrahedron, etc). 
