function camdolly(ax, dx, dy, dz, targetmode, coordsys)
%CAMDOLLY Dolly camera.
%   CAMDOLLY(DX, DY, DZ)  Moves the camera position and camera target
%   of the current axes by the amounts specified in DX, DY, and DZ.
% 
%   CAMDOLLY(DX, DY, DZ, targetmode) determines if the camera target
%   is moved.  If targetmode is 'movetarget' (the default), both the
%   camera position and the camera target are moved.  If targetmode is
%   'fixtarget', only the camera position is moved. 
% 
%   CAMDOLLY(DX, DY, DZ, targetmode, coordsys) determines the meaning
%   of DX, DY,  and DZ.  If coordsys is 'camera' (the default), DX and
%   DY move the camera up, down, right, and left in the camera's
%   coordinate system; DZ moves the camera along the line which passes
%   through the camera position and camera target. The units are
%   normalized to the scene being viewed.  For example, if DX is 1 the
%   camera is moved to the right, which pushes the scene to the left
%   edge of the box formed by the axes position.  If DZ is .5, the
%   camera is moved to a position half way in between the camera
%   position and the camera target.  If coordsys is 'pixels', DX and
%   DY are interpreted as a pixel offset and DZ is ignored. If
%   coordsys is 'data', DX, DY, and DZ are in data space (not the
%   camera's coordinate system).  
%
%   CAMDOLLY(AX, ...) uses axes AX instead of the current axes.
%
%   See also CAMORBIT, CAMPAN, CAMZOOM, CAMROLL.
 
%   Copyright 1984-2017 The MathWorks, Inc. 

if nargin > 3
    dz = convertStringsToChars(dz);
end

if nargin > 4
    targetmode = convertStringsToChars(targetmode);
end

if nargin > 5
    coordsys = convertStringsToChars(coordsys);
end

if nargin>6 || nargin<3
  error(message('MATLAB:camdolly:IncorrectNumberArguments'))
elseif nargin<6
  
  if any(ishghandle(ax,'axes'))
    if nargin<4 
      error(message('MATLAB:camdolly:InvalidNumberArguments'))
    else
      coordsys = 'camera';
      if nargin==4
	targetmode = 'movetarget';
      end
    end
  else
    if nargin==5
      coordsys = targetmode;
      targetmode = dz;
    elseif nargin==4
      coordsys = 'camera';
      targetmode = dz;
    else %nargin==3
      coordsys = 'camera';
      targetmode = 'movetarget';
    end
    
    dz = dy;
    dy = dx;
    dx = ax;
    ax = gca;
  end

end


darSave = ax.DataAspectRatio;
cpSave  = ax.CameraPosition;
ctSave  = ax.CameraTarget;
upSave  = ax.CameraUpVector;
cvaSave = ax.CameraViewAngle;

v = (ctSave-cpSave)./darSave;
dis = norm(v);
r = cross(v, upSave./darSave); 
u = cross(r, v);

r = r/norm(r);
u = u/norm(u);
v = v/dis;

if coordsys(1)=='d'   %data
  delta = [dx dy dz];
else
  if ~righthanded(ax), dx = -dx; end
  
  fov = 2*dis*tan(cvaSave/2*pi/180);
  
  if coordsys(1)=='p'  %pixels
    units = get(ax, 'units');
    set(ax, 'units', 'pix')
    pos = get(ax, 'pos');
    set(ax, 'units', units)
    pix = min(pos(3), pos(4));
    delta = fov/pix .* darSave .* ((dx * r) + (dy * u));
  else %camera
    delta = darSave .* (fov/2 .* ((dx * r) + (dy * u)) + (dz * v * dis));
  end
end

newcp = cpSave+delta;
newct = ctSave+delta;

if all(isfinite(newcp))
    ax.CameraUpVectorMode = 'manual';
    ax.CameraPosition = newcp;
end

if targetmode(1)=='m' && all(isfinite(newct))
    ax.CameraTarget = newct;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val=righthanded(ax)

dirs=get(ax, {'xdir' 'ydir' 'zdir'}); 
num=length(find(lower(cat(2,dirs{:}))=='n'));

val = mod(num,2);

