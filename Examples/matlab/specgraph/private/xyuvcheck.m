function [msg,nx,ny] = xyuvcheck(x,y,u,v)
%XYUVCHECK  Check arguments to 2D vector data routines.
%   [MSG,X,Y] = XYUVCHECK(X,Y,U,V) checks the input arguments
%   and returns either an error message structure in MSG 
%   or valid X,Y. The ERROR function describes the format 
%   and use of the error structure.
%
%   See also ERROR

%   Copyright 1984-2009 The MathWorks, Inc. 

msg = struct([]);
nx = x;
ny = y;

sz = size(u);
if ~isequal(size(v), sz)
  msg(1).identifier = 'MATLAB:xyuvcheck:UVSizeMismatch';
   msg(1).message = getString(message(msg(1).identifier));
  return
end

if ~ismatrix(u)
  msg(1).identifier = 'MATLAB:xyuvcheck:UVNot2D';
   msg(1).message = getString(message(msg(1).identifier));
  return
end
if min(sz)<2
  msg(1).identifier = 'MATLAB:xyuvcheck:UVPlanar';
   msg(1).message = getString(message(msg(1).identifier)); 
  return
end

nonempty = ~[isempty(x) isempty(y)];
if any(nonempty) && ~all(nonempty)
  msg(1).identifier = 'MATLAB:xyuvcheck:XYMixedEmpty';
   msg(1).message = getString(message(msg(1).identifier));
  return;
end

if ~isempty(nx) && ~isequal(size(nx), sz)
  nx = nx(:);
  if length(nx)~=sz(2)
    msg(1).identifier = 'MATLAB:xyuvcheck:XUSizeMismatch';
   msg(1).message = getString(message(msg(1).identifier));
    return
  else
    nx = repmat(nx',[sz(1) 1]);
  end
end

if ~isempty(ny) && ~isequal(size(ny), sz)
  ny = ny(:);
  if length(ny)~=sz(1)
    msg(1).identifier = 'MATLAB:xyuvcheck:YUSizeMismatch';
   msg(1).message = getString(message(msg(1).identifier));
    return
  else
    ny = repmat(ny,[1 sz(2)]);
  end
end


