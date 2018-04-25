function hh=tetramesh(tri,varargin)
%TETRAMESH Tetrahedron mesh plot
%   TETRAMESH(T,X,C) displays the tetrahedra defined in the M-by-4
%   matrix T as mesh.  T is usually the output of the Delaunay triangulation 
%   of a set of points in 3D. A row of T contains indices into X, the 
%   vertices of the tetrahedra. X is an N-by-3 matrix, representing N points 
%   in 3 dimensions. The tetrahedron colors are defined by the vector C, 
%   which is used as indices into the current colormap.
%
%   TETRAMESH(T,X) uses C=1:m as the color for the m tetrahedra. Each
%   tetrahedron will have a different color (modulo the number of
%   colors available in the current colormap).
%
%   TETRAMESH(TR) displays the tetrahedra in the triangulation TR.
%
%   H = TETRAMESH(...) returns a vector of tetrahedron handles. Each
%   element of H is a handle to the set of patches forming one
%   tetrahedron. One can use these handles to view a particular
%   tetrahedron by turning its 'visible' property 'on' and 'off'.
%
%   TETRAMESH(...,'param','value','param','value'...) allows
%   additional patch param/value pairs to be used when displaying the
%   tetrahedra.  For example, the default transparency parameter is
%   set to 0.9.  You can overwrite this value by using the param pair
%   ('FaceAlpha', value). The value has to be a number between 0 and 1.
%
%   Example:
%
%       d = [-1 1];
%       [x,y,z] = meshgrid(d,d,d);  % A cube
%       x = [x(:);0];
%       y = [y(:);0];
%       z = [z(:);0];    % [x,y,z] are corners of a cube plus the center.
%       dt = delaunayTriangulation(x,y,z);
%       Tes = dt(:,:);
%       X = [x(:) y(:) z(:)];
%       tetramesh(Tes,X);camorbit(20,0)
%
%       % Alternatively the delaunayTriangulation can be plotted directly
%       close(gcf);
%       tetramesh(dt);
%
%   See also TRIMESH, TRISURF, PATCH, DELAUNAY, triangulation, delaunayTriangulation.

%   Copyright 1984-2017 The MathWorks, Inc.

cax = axescheck(varargin{:});

numtri = size(tri,1);

if isa(tri, 'TriRep')
     if tri.size(1) == 0
        error(message('MATLAB:triplot:EmptyTri'));
     elseif tri.size(2) ~= 4
        error(message('MATLAB:triplot:NonTetrahedra'));
     elseif size(tri.X, 2) ~= 3
        error(message('MATLAB:triplot:NonPlanarTri'));
     end
     startparam = 1;
     X = tri.X;
     trids = tri(:,:);
     if (nargin == 1) || (mod(nargin-1,2) == 0)
       c = 1:numtri;
     else
       c = varargin{1};
       startparam = 2;
     end
elseif isa(tri, 'triangulation')
     if tri.size(1) == 0
        error(message('MATLAB:triplot:EmptyTri'));
     elseif tri.size(2) ~= 4
        error(message('MATLAB:triplot:NonTetrahedra'));
     elseif size(tri.Points, 2) ~= 3
        error(message('MATLAB:triplot:NonPlanarTri'));
     end
     startparam = 1;
     X = tri.Points;
     trids = tri(:,:);
     if (nargin == 1) || (mod(nargin-1,2) == 0)
       c = 1:numtri;
     else
       c = varargin{1};
       startparam = 2;
     end
else
    startparam = 2;
    if nargin < 2
      error(message('MATLAB:tetramesh:NotEnoughInputs')); 
    end
    X = varargin{1};
    trids = tri;
    if nargin > 2 && rem(nargin-2,2) == 1
      c = varargin{2};
      startparam = 3;
    else
      c = 1:numtri;
    end
end

if length(c) ~= numtri
  error(message('MATLAB:tetramesh:ColorLengthMismatch'));
end

cax = newplot(cax);
nextPlot = cax.NextPlot;
d = [1 1 1 2; 2 2 3 3; 3 4 4 4];
h = zeros(1,size(trids,1));
for n = 1:size(trids,1)
  y = trids(n,d);
  x1 = reshape(X(y,1),3,4);
  x2 = reshape(X(y,2),3,4);
  x3 = reshape(X(y,3),3,4);
  h(n)=patch(x1,x2,x3,[1 1 1 1]*c(n),'FaceAlpha', 0.9,...
             'Parent',cax,varargin{startparam:end});
end
if ~strcmp(nextPlot,'add')
    view(cax,3)
    axis(cax,'equal')
end

if nargout > 0
  hh = h;
end




