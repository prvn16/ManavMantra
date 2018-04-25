function camorbit(ax, dtheta, dphi, coordsys, direction)
%CAMORBIT Orbit camera.
%   CAMORBIT(DTHETA, DPHI)  Orbits (rotates) the camera position
%   of the current axes around the camera target by the amounts
%   specified in DTHETA and DPHI (both in degrees). DTHETA is the
%   horizontal rotation and DPHI is the vertical.
% 
%   CAMORBIT(DTHETA, DPHI, coordsys, direction) determines the center
%   of rotation. Coordsys can be 'data' (the default) or 'camera'.  If
%   coordsys is 'data' (the default), the camera position rotates
%   around a line specified by the camera target and direction.
%   Direction can be 'x', 'y', or 'z' (the default) or [X Y Z].  If
%   coordsys is 'camera', the rotation is around the camera target
%   point. 
%
%   CAMORBIT(AX, ...) uses axes AX instead of the current axes.
%
%   See also CAMDOLLY, CAMPAN, CAMZOOM, CAMROLL.
 
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
  error(message('MATLAB:camorbit:IncorrectNumberArguments'))
elseif nargin<5
  
  if any(ishghandle(ax,'axes'))
    if nargin<3 
      error(message('MATLAB:camorbit:NotEnoughInputs'))
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

if isa(ax,'matlab.graphics.chart.Chart')
    error(message('MATLAB:Chart:UnsupportedConvenienceFunction', 'camorbit', ax.Type));
end


pos  = get(ax, 'cameraposition' );
targ = get(ax, 'cameratarget'   );
dar  = get(ax, 'dataaspectratio');
up   = get(ax, 'cameraupvector' );

if ~righthanded(ax), dtheta = -dtheta; end

[newPos, newUp] = camrotate(pos,targ,dar,up,dtheta,dphi,coordsys,direction);

if all(isfinite(newPos))  
    ax.CameraPosition = newPos;
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

