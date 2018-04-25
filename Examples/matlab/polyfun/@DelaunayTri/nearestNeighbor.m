% nearestNeighbor  Search for the point closest to the specified location
%
%    DelaunayTri/nearestNeighbor will be removed in a future release.
%    Use delaunayTriangulation/nearestNeighbor instead.
%
%    PI = nearestNeighbor(DT, QX)  returns the index of nearest point in 
%    DT.X for each query point location in QX. The matrix QX is of size 
%    mpts-by-ndim, mpts being the number of query points and ndim the 
%    dimension of the space where the points reside. PI is a column vector 
%    of point indices that index into the points DT.X. The length of PI is 
%    equal to the number of query points mpts. 
%
%    PI = nearestNeighbor(DT, QX,QY) and PI = nearestNeighbor(DT, QX,QY,QZ) 
%    allow the query points to be specified in alternative column vector 
%    format when working in 2D and 3D.
%
%    [PI, D] = nearestNeighbor(DT,...)  returns in addition, the corresponding 
%    Euclidean distances D between the query points and their nearest 
%    neighbors. D is a column vector of length mpts.
%
%    Note: nearestNeighbor is not supported for 2D triangulations that have 
%          constrained edges.
%
%    Example: 	
%        x = rand(10,1)
%        y = rand(10,1)
%        dt = DelaunayTri(x,y)
%        % Find the points nearest the following query points
%        qrypts = [0.25 0.25; 0.5 0.5]
%        pid = nearestNeighbor(dt, qrypts)
%
%    See also DelaunayTri, DelaunayTri.pointLocation.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.