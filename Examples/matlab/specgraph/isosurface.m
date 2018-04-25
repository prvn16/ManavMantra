function [fout, vout, cout] = isosurface(varargin)
%ISOSURFACE  Isosurface extractor.
%   FV = ISOSURFACE(X,Y,Z,V,ISOVALUE) computes isosurface geometry for
%   data V at isosurface value ISOVALUE. Arrays (X,Y,Z) specify the points
%   at which the data V is given. The struct FV contains the faces and
%   vertices of the isosurface and can be passed directly to the PATCH
%   command.
%   
%   FV = ISOSURFACE(V,ISOVALUE) assumes [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
%        where [M,N,P]=SIZE(V). 
%   
%   FV = ISOSURFACE(X,Y,Z,V) or FV = ISOSURFACE(V) selects an
%   isosurface value automatically using the histogram of the
%   data. 
%   
%   FVC = ISOSURFACE(..., COLORS) interpolates the array COLORS onto
%   the scalar field and returns the interpolated values in
%   facevertexcdata. The size of the COLORS array must be the same
%   as V. 
%   
%   FV = ISOSURFACE(..., 'noshare') does not attempt to create
%   shared vertices. This is faster, but produces a larger set of
%   vertices.  
%   
%   FV = ISOSURFACE(..., 'verbose') prints progress messages to the
%        command window as the computation progresses. 
%   
%   [F, V] = ISOSURFACE(...) or  [F, V, C] = ISOSURFACE(...)
%   returns the faces and vertices (and facevertexcdata) in
%   separate arrays instead of a struct. 
%   
%   ISOSURFACE(...) With no output arguments, a patch is created
%   into the current axes with the computed faces and vertices. 
%   If no current axes exists, a new axes will be created with 
%   a 3-D view.
%   
%   Example 1:
%      [x y z v] = flow;
%      p = patch(isosurface(x, y, z, v, -3));
%      isonormals(x,y,z,v, p)
%      p.FaceColor = 'red';
%      p.EdgeColor = 'none';
%      daspect([1 1 1])
%      view(3)
%      camlight; lighting phong
%
%   Example 2:
%      [x y z v] = flow;
%      q = z./x.*y.^3;
%      p = patch(isosurface(x, y, z, q, -.08, v));
%      isonormals(x,y,z,q, p)
%      p.FaceColor = 'interp';
%      p.EdgeColor = 'none';
%      daspect([1 1 1]); axis tight; 
%      colormap(prism(28))
%      camup([1 0 0 ]); campos([25 -55 5]) 
%      camlight; lighting phong
%       
%
%   See also ISONORMALS, ISOCAPS, SMOOTH3, SUBVOLUME, REDUCEVOLUME,
%            REDUCEPATCH, SHRINKFACES.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

[x, y, z, data, colors, value, noshare, verbose] = parseargs(nargin,varargin);

if length(value)>1
  error(message('MATLAB:isosurface:ScalarIsovalue')); 
end

% Take this out when other data types are handled
data = datachk(data);
colors = datachk(colors);

[msg, x, y, z] = xyzvcheck(x,y,z,data);  error(msg) 


if ~isempty(colors) && ~isequal(size(colors), size(data))
  error(message('MATLAB:isosurface:ColorSizeMismatch')); 
end

if isempty(value)
  value = isovalue(data);
end

% Take this out when other data types are handled
value = datachk(value);

[v, f, c] = isosurf(data, colors, value, noshare, verbose);
v = v';
f = f';
c = c';
if isempty(v)
  v = [];
  f = [];
  c = [];
end

if ~isempty(x) && ~isempty(v)
  sz = size(x);
  if ~(isequal(x, 1:sz(2)) && isequal(y, 1:sz(1)) && isequal(z, 1:sz(3)))
    nv(:,1) = interp3( x,  v(:,1), v(:,2), v(:,3));
    nv(:,2) = interp3( y,  v(:,1), v(:,2), v(:,3));
    nv(:,3) = interp3( z,  v(:,1), v(:,2), v(:,3));
    v = nv;
  end
end

if nargout==0
  ax = [];
  fig = get(0, 'CurrentFigure'); 
  if ~isempty(fig)
    ax = get(fig, 'CurrentAxes');
  end

  p=patch('Faces', f, 'Vertices', v, 'FaceVertexCData', value, ...
          'FaceColor', 'flat', 'FaceLighting', 'gouraud', ...
          'EdgeColor', 'none', 'userdata', value);
      
  % Register handles with MATLAB code generator
  if ~isdeployed
      makemcode('RegisterHandle',p,'IgnoreHandle',p,'FunctionName','isosurface');        
  end
  
  if ~isempty(c)
    set(p, 'FaceVertexCData', c)
  end
  if ~isempty(x)
    isonormals(x,y,z,data, p);
  else
    isonormals(data, p);
  end
  
  if isempty(ax)
    view(3); 
    camlight;
  end
  
elseif nargout==1
  fout.vertices = v;
  fout.faces = f;
  if ~isempty(c)
    fout.facevertexcdata = c;
  end    
else
  fout = f;
  vout = v;
  if ~isempty(c)
    cout = c;
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, z, data, colors, value, noshare, verbose] = parseargs(nin, vargin)


x = [];
y = [];
z = [];
colors = [];
value = [];
noshare = 0;
verbose = 0;

for j = 1:2
  if nin>0
    lastarg = vargin{nin};
    if ischar(lastarg)
      if ~isempty(lastarg)
	if lower(lastarg(1))=='n' % noshare
	  noshare = 1;
	end
	if lower(lastarg(1))=='v' % verbose
	  verbose = 1;
	end
      end
      nin = nin - 1;
    end
  end
end

if nin==1                % isosurface(v)
  data = vargin{1};
elseif nin==2            % isosurface(v, isoval), isosurface(v, colors) 
  data = vargin{1};
  value = vargin{2};
  if isequal(size(value), size(data))
    colors = value;
    value = [];
  end
elseif nin==3            % isosurface(v, isoval, colors) 
  data = vargin{1};
  value = vargin{2};
  colors = vargin{3};
elseif nin==4            % isosurface(x,y,z,v)
  x = vargin{1};
  y = vargin{2};
  z = vargin{3};
  data = vargin{4};
elseif nin==5            % isosurface(x,y,z,v, isovalue), isosurface(x,y,z,v, colors)
  x = vargin{1};
  y = vargin{2};
  z = vargin{3};
  data = vargin{4};
  value = vargin{5};
  if isequal(size(value), size(data))
    colors = value;
    value = [];
  end
elseif nin==6            % isosurface(x,y,z,v, isovalue, colors)
  x = vargin{1};
  y = vargin{2};
  z = vargin{3};
  data = vargin{4};
  value = vargin{5};
  colors = vargin{6};
else
  error(message('MATLAB:isosurface:WrongNumberOfInputs')); 
end



