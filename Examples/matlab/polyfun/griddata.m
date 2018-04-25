
function [xq,yq,vq] = griddata(varargin)
%GRIDDATA Interpolates scattered data - generally to produce gridded data
%   Vq = griddata(X,Y,V,Xq,Yq) fits a surface of the form V = F(X,Y) to the
%   scattered data in (X, Y, V). The coordinates of the data points are 
%   defined by the vectors (X,Y) and V defines the corresponding values.
%   griddata interpolates the surface F at the query points (Xq,Yq) and 
%   returns the values in Vq. The query points (Xq, Yq) generally represent
%   a grid obtained from NDGRID or MESHGRID, hence the name GRIDDATA.
%
%   Vq = griddata(X,Y,Z,V,Xq,Yq,Zq) fits a hyper-surface of the form
%   V = F(X,Y,Z) to the scattered data in (X, Y, Z, V). The coordinates of 
%   the data points are defined by the vectors (X,Y,Z) and V defines the 
%   corresponding values. griddata interpolates the surface F at the query
%   points (Xq,Yq,Zq) and returns the values in Vq.   
%
%   Vq = griddata(X,Y,V, xq, yq) where xq is a row vector and yq is a
%   column vector, expands (xq, yq) via [Xq, Yq] = meshgrid(xq,yq).
%   [Xq, Yq, Vq] = griddata(X,Y,V, xq, yq) returns the grid coordinates
%   arrays in addition.
%   Note: The syntax for implicit meshgrid expansion of (xq, yq) will be 
%   removed in a future release.
%
%   GRIDDATA(..., METHOD) where METHOD is one of
%       'nearest'   - Nearest neighbor interpolation
%       'linear'    - Linear interpolation (default)
%       'natural'   - Natural neighbor interpolation
%       'cubic'     - Cubic interpolation (2D only)
%       'v4'        - MATLAB 4 griddata method (2D only)
%   defines the interpolation method. The 'nearest' and 'linear' methods 
%   have discontinuities in the zero-th and first derivatives respectively, 
%   while the 'cubic' and 'v4' methods produce smooth surfaces.  All the 
%   methods except 'v4' are based on a Delaunay triangulation of the data.
%
%   Example 1:
%      % Interpolate a 2D scattered data set over a uniform grid
%      xy = -2.5 + 5*gallery('uniformdata',[200 2],0);
%      x = xy(:,1); y = xy(:,2);
%      v = x.*exp(-x.^2-y.^2);
%      [xq,yq] = meshgrid(-2:.2:2, -2:.2:2);
%      vq = griddata(x,y,v,xq,yq);
%      mesh(xq,yq,vq), hold on, plot3(x,y,v,'o'), hold off
%
%   Example 2:
%      % Interpolate a 3D data set over a grid in the x-y (z=0) plane
%      xyz = -1 + 2*gallery('uniformdata',[5000 3],0);
%      x = xyz(:,1); y = xyz(:,2); z = xyz(:,3);
%      v = x.^2 + y.^2 + z.^2;
%      d = -0.8:0.05:0.8;
%      [xq,yq,zq] = meshgrid(d,d,0);
%      vq = griddata(x,y,z,v,xq,yq,zq);
%      surf(xq,yq,vq);
%
%   See also scatteredInterpolant, GRIDDATAN, MESHGRID, NDGRID, DELAUNAY, 
%   INTERPN.

%   Copyright 1984-2015 The MathWorks, Inc. 

narginchk(5,9);

numarg = nargin;
method = 'linear';
if iscell(varargin{numarg})
    error(message('MATLAB:griddata:DeprecatedOptions'));
elseif ischar(varargin{numarg}) || (isstring(varargin{numarg}) && isscalar(varargin{numarg}))
    method = varargin{numarg};
    method = lower(method);
    numarg = numarg-1;
end

if ~any(strcmp(method, {'nearest', 'linear', 'natural', 'cubic', 'v4'}))
    error(message('MATLAB:griddata:UnknownMethod'));
end

if  numarg == 5
    numdims = 2;
elseif numarg == 7
    numdims = 3;
else
    error(message('MATLAB:griddata:InvalidNumInputArgs'));
end

for i=1:(2*numdims)+1
    if (i ~= (numdims+1) && ~isreal(varargin{i}) )
        error(message('MATLAB:griddata:InvalidCoordsComplex'));
    elseif ~isnumeric(varargin{i})
        error(message('MATLAB:griddata:InvalidInputArgs'));
    end
end


for i=1:numarg
    if ndims(varargin{i}) > numdims
        error(message('MATLAB:griddata:HigherDimArray'));
    elseif ( issparse(varargin{i}) )
        error(message('MATLAB:griddata:InvalidDataSparse'));
    end
end

if  numarg == 5
    % potentially 2D validate the data
    % The xyzchk generates a meshgrid - support for this will be removed
    % in a future release.
    x = varargin{1};
    y = varargin{2};
    v = varargin{3};
    xq = varargin{4};
    yq = varargin{5};
    [msg,x,y,~,xq,yq] = xyzchk(x,y,v,xq,yq);
    if ~isempty(msg), error(message(msg.identifier)); end
    inputargs = {x,y,v,xq,yq};
elseif numarg == 7
    % Potentially 3D, check support for the method
    inputargs = varargin;
    if strcmp(method, 'cubic')
        error(message('MATLAB:griddata:CubicMethod3D'));
    elseif strcmp(method, 'v4')
        error(message('MATLAB:griddata:V4Method3D'));
    end
end

switch method
    case 'nearest'
        vq = useScatteredInterp(inputargs, numarg, method, 'nearest');        
    case {'linear', 'natural'}
        vq = useScatteredInterp(inputargs, numarg, method, 'none');
    case 'cubic'
        vq = cubic(x,y,v,xq,yq);
    case 'v4'
        vq = gdatav4(x,y,v,xq,yq);
end

if nargout<=1, xq = vq; end

%------------------------------------------------------------

function [x, y, v] = mergepoints2D(x,y,v)

% Sort x and y so duplicate points can be averaged

%Need x,y and z to be column vectors
sz = numel(x);
x = reshape(x,sz,1);
y = reshape(y,sz,1);
v = reshape(v,sz,1);
myepsx = eps(0.5 * (max(x) - min(x)))^(1/3);
myepsy = eps(0.5 * (max(y) - min(y)))^(1/3);


% look for x, y points that are indentical (within a tolerance)
% average out the values for these points
if isreal(v)
    xyv = builtin('_mergesimpts', [y, x, v], [myepsy, myepsx, Inf], 'average');
    x = xyv(:,2);
    y = xyv(:,1);
    v = xyv(:,3);
else
    % if z is imaginary split out the real and imaginary parts
    xyv = builtin('_mergesimpts', [y, x, real(v), imag(v)], ...
        [myepsy, myepsx, Inf, Inf], 'average');
    x = xyv(:,2);
    y = xyv(:,1);
    % re-combine the real and imaginary parts
    v = xyv(:,3) + 1i*xyv(:,4);
end
% give a warning if some of the points were duplicates (and averaged out)
if sz>numel(x)
    warning(message('MATLAB:griddata:DuplicateDataPoints'));
end

%------------------------------------------------------------

function vq = useScatteredInterp(inargs, numarg, method, emeth)

% Reference (nearest, linear):
%    David F. Watson, "Contouring: A guide to the analysis and display
%       of spacial data", Pergamon, 1994.
%
% Reference (natural):
%    Sibson, R. (1981). "A brief description of natural neighbor
%       interpolation (Chapter 2)".  In V. Barnett. Interpreting
%       Multivariate Data.  Chichester: John Wiley. pp. 21--36.

if numarg == 5
    F = scatteredInterpolant(inargs{1}(:),inargs{2}(:),inargs{3}(:), ...
        method, emeth);
    vq = F(inargs{4},inargs{5});
elseif numarg == 7
    F = scatteredInterpolant(inargs{1}(:),inargs{2}(:),inargs{3}(:), ...
        inargs{4}(:), method, emeth);
    vq = F(inargs{5},inargs{6},inargs{7});
end

%------------------------------------------------------------

function vq = cubic(x,y,v,xq,yq)
%TRIANGLE Triangle-based cubic interpolation

%   Reference: T. Y. Yang, "Finite Element Structural Analysis",
%   Prentice Hall, 1986.  pp. 446-449.
%
%   Reference: David F. Watson, "Contouring: A guide
%   to the analysis and display of spacial data", Pergamon, 1994.

% Triangulate the data

[x, y, v] = mergepoints2D(x,y,v);

dt = delaunayTriangulation(x,y);
scopedWarnOff = warning('off', 'MATLAB:triangulation:EmptyTri2DWarnId');
restoreWarnOff = onCleanup(@()warning(scopedWarnOff));
dtt = dt.ConnectivityList;
if isempty(dtt)
    warning(message('MATLAB:griddata:EmptyTriangulation'));
    vq = [];
    return
end

tri = dt.ConnectivityList;
% Find the enclosing triangle (t)
siz = size(xq);
t = dt.pointLocation(xq(:),yq(:));
t = reshape(t,siz);

if(isreal(v))
    vq = cubicmx(x,y,v,xq,yq,tri,t);
else
    vre = real(v);
    vim = imag(v);
    vqre = cubicmx(x,y,vre,xq,yq,tri,t);
    vqim = cubicmx(x,y,vim,xq,yq,tri,t);
    vq = complex(vqre,vqim);
end

%------------------------------------------------------------

function vq = gdatav4(x,y,v,xq,yq)
%GDATAV4 MATLAB 4 GRIDDATA interpolation

%   Reference:  David T. Sandwell, Biharmonic spline
%   interpolation of GEOS-3 and SEASAT altimeter
%   data, Geophysical Research Letters, 2, 139-142,
%   1987.  Describes interpolation using value or
%   gradient of value in any dimension.

[x, y, v] = mergepoints2D(x,y,v);

xy = x(:) + 1i*y(:);

% Determine distances between points
d = abs(xy - xy.');

% Determine weights for interpolation
g = (d.^2) .* (log(d)-1);   % Green's function.
% Fixup value of Green's function along diagonal
g(1:size(d,1)+1:end) = 0;
weights = g \ v(:);

[m,n] = size(xq);
vq = zeros(size(xq));
xy = xy.';

% Evaluate at requested points (xq,yq).  Loop to save memory.
for i=1:m
    for j=1:n
        d = abs(xq(i,j) + 1i*yq(i,j) - xy);
        g = (d.^2) .* (log(d)-1);   % Green's function.
        % Value of Green's function at zero
        g(d==0) = 0;
        vq(i,j) = g * weights;        
    end
end
