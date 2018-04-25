function [msg,nx,ny,nz] = xyzuvwcheck(x,y,z,u,v,w)
%XYZUVWCHECK  Check arguments to 3D vector data routines.
%   [MSG,X,Y,Z] = XYZUVWCHECK(X,Y,Z,U,V,W) checks the input arguments
%   and returns either an error message structure in MSG or valid 
%   X,Y,Z. The ERROR function describes the format and use of the
%   error structure.
%
%   See also ERROR

%   Copyright 1984-2005 The MathWorks, Inc. 

msg = struct([]);
nx = x;
ny = y;
nz = z;

sz = size(u);
if ~isequal(size(v), sz) || ~isequal(size(w), sz)
  msg(1).identifier = 'MATLAB:xyzuvwcheck:UVWSizeMismatch';
    msg(1).message = getString(message(msg(1).identifier));
  return
end

if ndims(u)~=3
  msg(1).identifier = 'MATLAB:xyzuvwcheck:UVWNot3D';
    msg(1).message = getString(message(msg(1).identifier));
  return
end
if min(sz)<2
  msg(1).identifier = 'MATLAB:xyzuvwcheck:UVWPlanar';
    msg(1).message = getString(message(msg(1).identifier)); 
  return
end

nonempty = ~[isempty(x) isempty(y) isempty(z)];
if any(nonempty) && ~all(nonempty)
  msg(1).identifier = 'MATLAB:xyzuvwcheck:XYZMixedEmpty';
    msg(1).message = getString(message(msg(1).identifier));
  return;
end

if ~isempty(nx) && ~isequal(size(nx), sz)
  nx = nx(:);
  if length(nx)~=sz(2)
    msg(1).identifier = 'MATLAB:xyzuvwcheck:XUSizeMismatch';
    msg(1).message = getString(message(msg(1).identifier));
    return
  else
    nx = repmat(nx',[sz(1) 1 sz(3)]);
  end
end

if ~isempty(ny) && ~isequal(size(ny), sz)
  ny = ny(:);
  if length(ny)~=sz(1)
    msg(1).identifier = 'MATLAB:xyzuvwcheck:YUSizeMismatch';
    msg(1).message = getString(message(msg(1).identifier));
    return
  else
    ny = repmat(ny,[1 sz(2) sz(3)]);
  end
end

if ~isempty(nz) && ~isequal(size(nz), sz)
  nz = nz(:);
  if length(nz)~=sz(3)
    msg(1).identifier = 'MATLAB:xyzuvwcheck:ZUSizeMismatch';
    msg(1).message = getString(message(msg(1).identifier));
    return
  else
    nz = repmat(reshape(nz,[1 1 length(nz)]),[sz(1) sz(2) 1]);
  end
end

