function [A,xy] = unmesh(M)
%UNMESH Convert a list of edges to a graph or matrix.
%   [A,XY] = UNMESH(E) returns the Laplacian matrix A and mesh vertex
%   coordinate matrix XY for the M-by-4 edge matrix E.  Each row of
%   the edge matrix must contain the coordinates [x1 y1 x2 y2] of the
%   edge endpoints. The Laplacian matrix A is a symmetric adjacency
%   matrix with -1 for edges and degrees on the diagonal. Each row of
%   XY is a coordinate [x y] of a mesh point.
%
%   See also GPLOT.

%   John Gilbert, 1990.
%   Copyright 1984-2013 The MathWorks, Inc. 

% Discretize x and y with "range" steps, 
% equating coordinates that round to the same step.


range = round(eps^(-1/3));

[m,k] = size(M);
if k ~= 4, 
  error (message('MATLAB:unmesh:WrongRowForm'))
end

x = [ M(:,1) ; M(:,3) ];
y = [ M(:,2) ; M(:,4) ];
xmax = max(x);
ymax = max(y);
xmin = min(x);
ymin = min(y);
xsf = max(xmax - xmin, 1);
ysf = max(ymax - ymin, 1);
xscale = (range-1)/xsf;
yscale = (range-1)/ysf;

% The "name" of each (x,y) coordinate (i.e. vertex)
% is scaledx + scaledy/range .

xnames = round( (x - xmin)*xscale );
ynames = round( (y - ymin)*yscale );
xynames = xnames+1 + ynames/range;

% vnames = the sorted list of vertex names, duplicates removed.

[vnames, ind] = sort(xynames);
f = find(diff( [-Inf; vnames] ));
vnames = vnames(f);
ind = ind(f);
n = length(vnames);

% x and y are the rounded coordinates, un-scaled.

x = x(ind);
y = y(ind);
xy = [x y];

% Fill in the edge list one vertex at a time.

ij = zeros(2*m,1);
for v = 1:n,
    f = find( xynames == vnames(v) );
    ij(f) = repmat(v,length(f),1);
end;

% Fill in the edges of A.

i = ij(1:m);
j = ij(m+1:2*m);
A = sparse(i,j,1,n,n);

% Make A the symmetric Laplacian.

A = -spones(A+A');
A = A - diag(sum(A));

