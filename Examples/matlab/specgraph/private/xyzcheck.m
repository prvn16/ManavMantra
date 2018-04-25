function [msg,nx,ny] = xyzcheck(x,y,z,zname)
%XYZCHECK  Check arguments to 2.5D data routines.
%   [MSG,X,Y] = XYZCHECK(X,Y,Z) checks the input arguments
%   and returns either an error message structure in MSG or 
%   valid X,Y. The ERROR function describes the format and 
%   use of the error structure.
%
%   See also ERROR

%   Copyright 1984-2011 The MathWorks, Inc. 

msg = struct([]);
nx = x;
ny = y;

sz = size(z);

if nargin < 4
    zname = 'Z';
end

if ~ismatrix(z)
  msg(1).identifier = 'MATLAB:xyzcheck:ZNot2D';
   msg(1).message = getString(message(msg(1).identifier,zname)); 
  return
end
if min(sz)<2
  msg(1).identifier = 'MATLAB:xyzcheck:ZPlanar';
   msg(1).message = getString(message(msg(1).identifier,zname)); 
  return
end

nonempty = ~[isempty(x) isempty(y)];
if any(nonempty) && ~all(nonempty)
  msg(1).identifier = 'MATLAB:xyzcheck:XYMixedEmpty';
   msg(1).message = getString(message(msg(1).identifier));
  return;
end

if ~isempty(nx) && ~isequal(size(nx), sz)
  nx = nx(:);
  if length(nx)~=sz(2)
    msg(1).identifier = 'MATLAB:xyzcheck:XZSizeMismatch';
   msg(1).message = getString(message(msg(1).identifier,zname,zname));
    return
  else
    nx = repmat(nx',[sz(1) 1]);
  end
end

if ~isempty(ny) && ~isequal(size(ny), sz)
  ny = ny(:);
  if length(ny)~=sz(1)
    msg(1).identifier = 'MATLAB:xyzcheck:YZSizeMismatch';
   msg(1).message = getString(message(msg(1).identifier,zname,zname));
    return
  else
    ny = repmat(ny,[1 sz(2)]);
  end
end

