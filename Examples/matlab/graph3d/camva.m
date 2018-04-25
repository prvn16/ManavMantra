function a = camva(arg1, arg2)
%CAMVA Camera view angle.
%   CVA = CAMVA             gets the camera view angle of the current
%                              axes. 
%   CAMVA(val)              sets the camera view angle.
%   CVAMODE = CAMVA('mode') gets the camera view angle mode.
%   CAMVA(mode)             sets the camera view angle mode.
%                              (mode can be 'auto' or 'manual')
%   CAMVA(AX,...)           uses axes AX instead of current axes.
%
%   CAMVA sets or gets the CameraViewAngle or CameraViewAngleMode
%   property of an axes.
%
%   See also CAMPOS, CAMTARGET, CAMPROJ, CAMUP.
 
%   Copyright 1984-2017 The MathWorks, Inc. 

if nargin > 0
    arg1 = convertStringsToChars(arg1);
end

if nargin > 1
    arg2 = convertStringsToChars(arg2);
end

if nargin == 0
  a = get(gca,'cameraviewangle');
else
  if isscalar(arg1) && ishghandle(arg1,'axes')
    ax = arg1;
    if nargin==2
      val = arg2;
    else
      a = get(ax,'cameraviewangle');
      return
    end
  else
    if nargin==2
      error(message('MATLAB:camva:WrongNumberArguments'))
    else
      ax = gca;
      val = arg1;
    end
  end
    
  if ischar(val)
    if(strcmp(val,'mode'))
      a = get(ax,'cameraviewanglemode');
    else
      set(ax,'cameraviewanglemode',val);
    end
  else
    set(ax,'cameraviewangle',val);
  end
end


