function [fout, vout] = shrinkfaces(varargin)
%SHRINKFACES  Reduce size of patch faces.
%   SHRINKFACES(P, SF) shrinks the area of the faces in patch P to shrink
%   factor SF. If SF is 0.6, each face is shrunk to 60% of its original
%   area. If the patch contains shared vertices, non-shared vertices are
%   created before reduction.
%   
%   NFV = SHRINKFACES(P, SF) returns the faces and vertices but does not
%   set the Faces and Vertices properties of patch P.  The struct NFV
%   contains the new faces and vertices.
%   
%   NFV = SHRINKFACES(FV, SF) uses faces and vertices from struct FV.
%
%   SHRINKFACES(P) or SHRINKFACES(FV) assumes a shrink factor of .3.
%   
%   NFV = SHRINKFACES(F, V, SF) uses faces and vertices in arrays F and V.
%   
%   [NF, NV] = SHRINKFACES(...) returns the faces and vertices in two
%              arrays instead of a struct.
%   Example:
%      [x y z v] = flow;
%      [x y z v] = reducevolume(x,y,z,v, 2);
%      fv = isosurface(x, y, z, v, -3);
%      subplot(1,2,1)
%      p = patch(fv);
%      p.FaceColor = [.5 .5 .5];
%      p.EdgeColor = 'black';
%      daspect([1 1 1]); view(3); axis tight
%      title('Original')
%      subplot(1,2,2)
%      p = patch(shrinkfaces(fv, .2)); % shrink faces to 20% of original 
%      p.FaceColor = [.5 .5 .5]; 
%      p.EdgeColor = 'black';
%      daspect([1 1 1]); view(3); axis tight
%      title('After Shrinking')
%   
%   See also ISOSURFACE, ISONORMALS, ISOCAPS, SMOOTH3, SUBVOLUME, 
%            REDUCEVOLUME, REDUCEPATCH.

%   Copyright 1984-2017 The MathWorks, Inc.

[p, faces, verts, sf] = parseargs(nargin,varargin);

if length(sf)>1
  error(message('MATLAB:shrinkfaces:NonScalarFactor')); 
end
if sf<0
  error(message('MATLAB:shrinkfaces:NonPositiveFactor')); 
end


if isempty(sf)
  sf = sqrt(.3);
end

nanindex = isnan(faces);
[faces, verts]=facesvertsnoshare(faces, verts);

fcols = size(faces,2);
coords = verts(faces',:);
facexyz = reshape(coords,fcols,numel(coords)/fcols);

av = nanmean(facexyz);
av = repmat(av,[fcols 1]);

facexyz = facexyz*sf - av*(sf-1);

verts(faces',:) = reshape(facexyz, size(coords));
faces(nanindex) = nan; 

if nargout==0
  if ~isempty(p)
    set(p, 'faces', faces, 'vertices', verts);
  else
    fout.faces = faces;
    fout.vertices = verts;
  end
elseif nargout==1
  fout.faces = faces;
  fout.vertices = verts;
else
  fout = faces;
  vout = verts;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p, faces, verts, sf] = parseargs(nin, vargin)

p=[];
sf = [];

if nin==1 || nin==2           % shrinkfaces(p), shrinkfaces(fv), shrinkfaces(arg, sf) 
  firstarg = vargin{1};
  if isstruct(firstarg)
    faces = firstarg.faces;
    verts = firstarg.vertices;
  elseif all(ishandle(firstarg)) && all(strcmp(get(firstarg, 'type'), 'patch'))
    p = firstarg;
    faces = get(p, 'faces');
    verts = get(p, 'vertices');
  else
    error(message('MATLAB:shrinkfaces:InvalidFirstArgument'));
  end
  if nin==2
    sf = vargin{2};
  end
elseif nin==3            %shrinkfaces(f, v, sf)
  faces = vargin{1};
  verts = vargin{2};
  sf = vargin{3};
else
  error(message('MATLAB:shrinkfaces:WrongNumberOfInputs')); 
end

if ~isempty(sf)
  if sf>=0
    sf = sqrt(sf);
  else
    sf = -sqrt(-sf);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [newf, newv]=facesvertsnoshare(f, v)

fcols = size(f,2);
fmax = 1+max(f(:));
nanindex = isnan(f);
f(nanindex)=fmax;
findex = f';
v(fmax,:) = nan*zeros(1,size(v,2));

newv = v(findex,:);
vrows = size(newv,1);
newf = reshape(1:vrows, fcols, vrows/fcols)';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = nanmean(x)
%NANMEAN Average or mean ignoring NaNs.
%   NANMEAN(X) returns the average treating NaNs as missing values.  
%   For vectors, NANMEAN(X) is the mean value of the non-NaN
%   elements in X.  For matrices, NANMEAN(X) is a row vector
%   containing the mean value of each column, ignoring NaNs.

if isempty(x) % Check for empty input.
    y = NaN;
    return
end

% Replace NaNs with zeros.
nans = isnan(x);
i = find(nans);
x(i) = zeros(size(i));

if min(size(x))==1
  count = length(x)-sum(nans);
else
  count = size(x,1)-sum(nans);
end

% Protect against a column of all NaNs
i = find(count==0);
count(i) = ones(size(i));
y = sum(x)./count;
y(i) = i + NaN;


