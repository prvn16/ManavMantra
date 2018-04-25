function camroll(arg1, arg2)
%CAMROLL Roll camera.
%   CAMROLL(DTHETA) rolls the camera of the current axes DTHETA
%   degrees clockwise around the line which passes through the camera
%   position and camera target.
%   CAMROLL(AX, DTHETA) uses axes AX instead of the current axes.
%
%   CAMROLL sets the CameraUpVector property of an axes.
%
%   See also CAMORBIT, CAMPAN, CAMZOOM, CAMDOLLY.
 
%   Copyright 1984-2005 The MathWorks, Inc. 

if nargin==1
  ax = gca;
  dtheta = arg1;
elseif nargin==2
  ax = arg1;
  dtheta = arg2;
else
  error(message('MATLAB:camroll:TooManyInputs'))
end

% Normalize by the data aspect ratio so that the camera rolls uniformly,
% independent of the limits
darSave = ax.DataAspectRatio;
cpSave  = (ax.CameraPosition) ./darSave;
ctSave  = (ax.CameraTarget)   ./darSave;
upSave  = (ax.CameraUpVector) ./darSave;

if ~righthanded(ax), dtheta = -dtheta; end

v = (ctSave-cpSave);
v = v/norm(v);
alph = (dtheta)*pi/180;
cosa = cos(alph);
sina = sin(alph);
vera = 1 - cosa;
x = v(1);
y = v(2);
z = v(3);
rot = [cosa+x^2*vera x*y*vera-z*sina x*z*vera+y*sina; ...
       x*y*vera+z*sina cosa+y^2*vera y*z*vera-x*sina; ...
       x*z*vera-y*sina y*z*vera+x*sina cosa+z^2*vera]';

r = cross(v, upSave);
u = cross(r, v);
u = u/norm(u);
newUp = u*rot;

newUp = (newUp.*darSave)/norm(newUp.*darSave);
ax.CameraUpVector = newUp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val=righthanded(ax)

dirs=get(ax, {'XDir' 'YDir' 'ZDir'}); 
num=length(find(lower(cat(2,dirs{:}))=='n'));

val = mod(num,2);

