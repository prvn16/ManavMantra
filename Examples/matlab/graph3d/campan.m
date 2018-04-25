function campan(ax, dtheta, dphi, coordsys, direction)
%CAMPAN Pan camera.
%   CAMPAN(DTHETA, DPHI)  Pans (rotates) the camera target of the
%   current axes around the camera position by the amounts specified
%   in DTHETA and DPHI (both in degrees). DTHETA is the horizontal
%   rotation and DPHI is the vertical.    
% 
%   CAMPAN(DTHETA, DPHI, coordsys, direction) determines the center of
%   rotation. Coordsys can be 'data' (the default) or 'camera'.  If
%   coordsys is 'data' (the default), the camera target rotates around
%   a line specified by the camera position and direction. Direction
%   can be 'x', 'y', or 'z' (the default) or [X Y Z].  If coordsys is
%   'camera', the rotation is around the camera position point.   
%
%   CAMPAN(AX, ...) uses axes AX instead of the current axes.
%
%   See also CAMDOLLY, CAMORBIT, CAMZOOM, CAMROLL.
 
%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 2
    dphi = convertStringsToChars(dphi);
end

if nargin > 3
    coordsys = convertStringsToChars(coordsys);
end

if nargin > 4
    direction = convertStringsToChars(direction);
end

if nargin>5 || nargin<2
  error(message('MATLAB:campan:InvalidNumberArguments'))
elseif nargin<5
  
  if any(ishghandle(ax,'axes'))
    if nargin<3 
      error(message('MATLAB:campan:NotEnoughInputs'))
    else
      direction = [0 0 1];
      if nargin==3
	coordsys = 'data';
      end
    end
  else
    if nargin==4
      direction = coordsys;
      coordsys  = dphi;
    elseif nargin==3
      direction = [0 0 1];
      coordsys  = dphi;
    else %nargin==2
      direction = [0 0 1];
      coordsys  = 'data';
    end
    
    dphi   = dtheta;
    dtheta = ax;
    ax     = gca;
  end

end


pos  = ax.CameraPosition;
targ = ax.CameraTarget;
dar  = ax.DataAspectRatio;
up   = ax.CameraUpVector;

if righthanded(ax), dtheta = -dtheta; end

[newTarg, newUp] = camrotate(targ,pos, dar,up,dtheta,dphi,coordsys,direction);

if all(isfinite(newTarg))
    ax.CameraTarget = newTarg;
end
if all(isfinite(newUp))
    ax.CameraUpVector = newUp;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val=righthanded(ax)

dirs=get(ax, {'xdir' 'ydir' 'zdir'}); 
num=length(find(lower(cat(2,dirs{:}))=='n'));

val = mod(num,2);

