function ret = smooth3(data, filt, sz, arg)
%SMOOTH3  Smooth 3D data.
%   W = SMOOTH3(V) smoothes input data V. The smoothed data is returned
%       in W.
%   
%   W = SMOOTH3(V, METHOD) METHOD can be either of the filters 'gaussian'
%       or 'box' (default) and determines the convolution kernel.
%   
%   W = SMOOTH3(V, METHOD, SIZE) sets the size of the convolution kernel
%       (default is [3 3 3]). If SIZE is a scalar, the size is interpreted
%       as [SIZE SIZE SIZE].
%   
%   W = SMOOTH3(V, METHOD, SIZE, ARG) sets an attribute of the
%       convolution kernel. When METHOD is 'gaussian', ARG is the standard
%       deviation (default is .65).
%
%   Example:
%      data = rand(10,10,10);
%      data = smooth3(data,'box',5);
%      p = patch(isosurface(data,.5), ...
%          'FaceColor', 'blue', 'EdgeColor', 'none');
%      p2 = patch(isocaps(data,.5), ...
%          'FaceColor', 'interp', 'EdgeColor', 'none');
%      isonormals(data,p)
%      view(3); axis vis3d tight
%      camlight; lighting phong
%
%   See also ISOSURFACE, ISOCAPS, ISONORMALS, SUBVOLUME, REDUCEVOLUME,
%            REDUCEPATCH.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 1
    filt = convertStringsToChars(filt);
end

if nargin==1      %smooth3(data)
  filt = 'b';
  sz = 3;
  arg = .65;
elseif nargin==2  %smooth3(data, filter)
  sz = 3;
  arg = .65;
elseif nargin==3  %smooth3(data, filter, sz)
  arg = .65;
elseif nargin>4 || nargin==0
  error(message('MATLAB:smooth3:WrongNumberOfInputs')); 
end

if ndims(data)~=3
  error(message('MATLAB:smooth3:VDataNot3D'));
end

if length(sz)==1
  sz = [sz sz sz];
elseif numel(sz)~=3
  error(message('MATLAB:smooth3:InvalidSizeInput'))
end

sz = sz(:)';

padSize = (sz-1)/2;

if ~isequal(padSize, floor(padSize)) || any(padSize<0)
  error(message('MATLAB:smooth3:InvalidSizeValues'));
end

if filt(1)=='g' %gaussian
  smooth = gaussian3(sz,arg);
elseif filt(1)=='b' %box
  smooth = ones(sz)/prod(sz);
else
  error(message('MATLAB:smooth3:UnknownFilter'));
end

ret=convn(padreplicate(data,padSize),smooth, 'valid');


function h = gaussian3(P1, P2)
%3D Gaussian lowpass filter
%
%   H = gausian3(N,SIGMA) returns a rotationally
%   symmetric 3D Gaussian lowpass filter with standard deviation
%   SIGMA (in pixels). N is a 1-by-3 vector specifying the number
%   of rows, columns, pages in H. (N can also be a scalar, in 
%   which case H is NxNxN.) If you do not specify the parameters,
%   the default values of [3 3 3] for N and 0.65 for
%   SIGMA.


if nargin>0
  if ~(all(size(P1)==[1 1]) || all(size(P1)==[1 3]))
     error(message('MATLAB:smooth3:InvalidFirstInput'));
  end
  if length(P1)==1
      siz = [P1 P1 P1]; 
  else 
      siz = P1;
  end
end

if nargin<1
    siz = [3 3 3]; 
end
if nargin<2
    std = .65; 
else 
    std = P2; 
end
[x,y,z] = meshgrid(-(siz(2)-1)/2:(siz(2)-1)/2, -(siz(1)-1)/2:(siz(1)-1)/2, -(siz(3)-1)/2:(siz(3)-1)/2);
h = exp(-(x.*x + y.*y + z.*z)/(2*std*std));
h = h/sum(h(:));


function b=padreplicate(a, padSize)
%Pad an array by replicating values.
numDims = length(padSize);
idx = cell(numDims,1);
for k = 1:numDims
  M = size(a,k);
  onesVector = ones(1,padSize(k));
  idx{k} = [onesVector 1:M M*onesVector];
end

b = a(idx{:});


