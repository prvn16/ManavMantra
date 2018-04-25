function hh = triplot(tri,varargin)
%TRIPLOT Plots a 2D triangulation
%   TRIPLOT(TRI,X,Y) displays the triangles defined in the
%   M-by-3 matrix TRI.  A row of TRI contains indices into X,Y that
%   define a single triangle. The default line color is blue.
%
%   TRIPLOT(TR) displays the triangles in the triangulation TR.
%
%   TRIPLOT(...,COLOR) uses the string COLOR as the line color.
%
%   H = TRIPLOT(...) returns a line handle representing the displayed
%   triangles edges.
%
%   TRIPLOT(...,'param','value','param','value'...) allows additional
%   line param/value pairs to be used when creating the plot.
%
%   Example 1:
%       X = rand(10,2);
%       dt = delaunayTriangulation(X);
%       triplot(dt)
%
%   Example 2:
%       % Plotting a Delaunay triangulation in face-vertex format
%       X = rand(10,2);
%       dt = delaunayTriangulation(X);
%       tri = dt(:,:);
%       triplot(tri, X(:,1), X(:,2));
%
%   See also TRISURF, TRIMESH, DELAUNAY, triangulation, delaunayTriangulation.

%   Copyright 1984-2015 The MathWorks, Inc. 


narginchk(1,inf);

start = 1;

if isa(tri, 'TriRep')
     if tri.size(1) == 0
        error(message('MATLAB:triplot:EmptyTri'));
     elseif tri.size(2) ~= 3
        error(message('MATLAB:triplot:NonTriangles'));
     end
    x = tri.X(:,1);
    y = tri.X(:,2);
    edges = tri.edges();
    if (nargin == 1) || (mod(nargin-1,2) == 0)
      c = 'blue';
    else
      c = varargin{1};
      start = 2;
    end
elseif isa(tri, 'triangulation')
     if tri.size(1) == 0
        error(message('MATLAB:triplot:EmptyTri'));
     elseif tri.size(2) ~= 3
        error(message('MATLAB:triplot:NonTriangles'));
     end
    x = tri.Points(:,1);
    y = tri.Points(:,2);
    edges = tri.edges();
    if (nargin == 1) || (mod(nargin-1,2) == 0)
      c = 'blue';
    else
      c = varargin{1};
      start = 2;
    end     
else
    x = varargin{1};
    y = varargin{2};
    warnState = warning('off','MATLAB:triangulation:PtsNotInTriWarnId');
    tr = triangulation(tri,x(:),y(:));
    warning(warnState);
    edges = tr.edges();
    if (nargin == 3) || (mod(nargin-3,2) == 0)
      c = 'blue';
      start = 3;
    else 
      c = varargin{3};
      start = 4;
    end
end

x = x(edges)';
y = y(edges)';
nedges = size(x,2);
x = [x; NaN(1,nedges)];
y = [y; NaN(1,nedges)];
x = x(:);
y = y(:);
h = plot(x,y,c,varargin{start:end});
if nargout == 1, hh = h; end
