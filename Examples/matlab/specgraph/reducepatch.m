function [fout, vout] = reducepatch(varargin)
%REDUCEPATCH  Reduce number of patch faces.
%   REDUCEPATCH(P, R) reduces the number of faces in patch P while trying
%   to preserve the overall shape of the patch.  If R is less than or
%   equal to 1, R is interpreted as a fraction of the original faces; for
%   example, if R is 0.2, 20% of the faces will be kept. If R is greater
%   than 1, then R is the target number of faces. For example, if R were
%   400, then the number of faces would be reduced until there were 400
%   faces remaining. If the patch contains non-shared vertices, shared
%   vertices are computed before reduction. If the faces of the patch are
%   not triangles, the faces are triangulated before reduction. The faces
%   returned are always triangles.
%   
%   NFV = REDUCEPATCH(P, R) returns the reduced set of faces and vertices
%   but does not set the Faces and Vertices properties of patch P.  The 
%   struct NFV contains the faces and vertices after reduction.
%   
%   NFV = REDUCEPATCH(FV, R) uses faces and vertices from struct FV. 
%   
%   REDUCEPATCH(P) or NFV = REDUCEPATCH(FV) assumes a reduction of .5.
%
%   REDUCEPATCH(...,'fast') assumes the vertices are unique and
%   does not compute shared vertices.
%
%   REDUCEPATCH(...,'verbose') prints progress messages to the
%   command window as the computation progresses.  
%
%   NFV = REDUCEPATCH(F, V, R) uses faces and vertices in arrays F and V.
%   
%   [NF, NV] = REDUCEPATCH(...) returns the faces and vertices in two 
%              arrays instead of a struct.
%
%   NOTE: The number of output triangles might not be exactly as specified
%   by the reduction value, especially if the input faces were not
%   triangles.
%
%   Example:
%      [x y z v] = flow;
%      fv = isosurface(x, y, z, v, -3);
%      subplot(1,2,1)
%      p = patch(fv);
%      p.FaceColor = [.5 .5 .5];
%      p.EdgeColor = 'black';
%      daspect([1 1 1]); view(3); axis tight
%      title([num2str(length(p.Faces)) ' Faces'])
%      subplot(1,2,2)
%      p = patch(fv);
%      p.FaceColor = [.5 .5 .5];
%      p.EdgeColor = 'black';
%      daspect([1 1 1]); view(3); axis tight
%      reducepatch(p, .15) % keep 15 percent of the faces 
%      title([num2str(length(p.Faces)) ' Faces'])
%
%   See also ISOSURFACE, ISOCAPS, ISONORMALS, SMOOTH3, SUBVOLUME,
%            REDUCEVOLUME.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

[p, faces, verts, reduction, fast, verbose] = parseargs(nargin,varargin);

if isempty(reduction)
    reduction = .5;
end

if length(reduction)>1
  error(message('MATLAB:reducepatch:NonScalarReduction')); 
end
if reduction<0 || isnan(reduction)
  error(message('MATLAB:reducepatch:NonFinitePositiveReduction')); 
end

if min(faces(:))<1 
  error(message('MATLAB:reducepatch:FaceValuesTooSmall')); 
end
if max(faces(:))>size(verts,1)
  error(message('MATLAB:reducepatch:FaceValuesTooLarge')); 
end
  
if size(verts,2)==2
  verts(:,3) = 0*verts(:,1);
end

[frows, fcols] = size(faces);
if fcols>3   % triangulate using very simple algorithm
  newfaces = zeros(frows*(fcols-2),3);
  newfaces(:,1) = repmat(faces(:,1),fcols-2,1);
  for k = 2:fcols-1
    newfaces( (1:frows)+frows*(k-2), 2:3) = [faces(:,k) faces(:,k+1)];
  end
  faces = newfaces;
end

if fast==0
  %uniquify the vertices
  [verts,i,j] = unique(verts, 'rows'); %#ok
  j(end+1) = nan;
  faces(isnan(faces)) = length(j);
  if size(faces,1)==1
    faces = j(faces)';
  else
    faces = j(faces);
  end
end

numFaces =  size(faces,1);
if reduction>0 && reduction<=1
  reduction = numFaces*reduction;
end

reduction = min(numFaces+1, reduction);

%remove the nans
if ~isempty(faces)
  pos = isnan(faces(:,1));
  faces(pos,:) = [];
  pos = isnan(faces(:,2));
  faces(pos,2) = faces(pos,1);
  pos = isnan(faces(:,3));
  faces(pos,3) = faces(pos,2);
end

%call the mex file
[v, f] = reducep(double(verts), double(faces), double(reduction), double(verbose));

if isempty(v), v = []; end
if isempty(f), f = []; end

if nargout==0
  if ~isempty(p)
    set(p, 'faces', f, 'vertices', v);
  else
    fout.faces = f;
    fout.vertices = v;
  end
elseif nargout==1
  fout.faces = f;
  fout.vertices = v;
else
  fout = f;
  vout = v;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p, faces, verts, r, fast, verbose] = parseargs(nin, vargin)

p=[];
r = [];
fast = 0;
verbose = 0;

for j=1:2
  if nin>0
    lastarg = vargin{nin};
    if ischar(lastarg) % reducepatch(...,'fast') or reducepatch(...,'verbose')
      if ~isempty(lastarg)
	lastarg = lower(lastarg);
	if lastarg(1)=='f'
	  fast = 1;
	end
	if lastarg(1)=='v'
	  verbose = 1;
	end
      end
      nin = nin - 1;
    end
  end
end

if nin==1 || nin==2  % reducepatch(p),  reducepatch(fv), reducepatch(arg, r)
  firstarg = vargin{1};
  if isstruct(firstarg)
    faces = firstarg.faces;
    verts = firstarg.vertices;
  elseif isscalar(firstarg) && ishandle(firstarg) && strcmp(get(firstarg, 'type'), 'patch')
    p = firstarg;
    faces = get(p, 'faces');
    verts = get(p, 'vertices');
  else
    error(message('MATLAB:reducepatch:InvalidFirstArgument'));
  end
  if nin==2
    r = vargin{2};
  end
elseif nin==3   % reducepatch(f, v, r)
  faces = vargin{1};
  verts = vargin{2};
  r = vargin{3};
else
  error(message('MATLAB:reducepatch:WrongNumberOfInputs')); 
end



