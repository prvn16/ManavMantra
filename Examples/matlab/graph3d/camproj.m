function a = camproj(arg1, arg2)
%CAMPROJ Camera projection.
% 
%   PROJ = CAMPROJ       gets the camera projection of the current
%                           axes. 
%   CAMPROJ(projection)  sets the camera projection.  
%   CAMPROJ(AX,...)      uses axes AX instead of current axes.
%
%   Projection can be 'orthographic' (default) or 'perspective'. 
%
%   CAMPROJ sets or gets the Projection property of an axes.
%
%   See also CAMPOS, CAMTARGET, CAMVA, CAMUP.

%   Copyright 1984-2005 The MathWorks, Inc. 

if nargin == 0
  ax = gca;
  a = get(ax,'projection');
else
  if isscalar(arg1) && ishghandle(arg1,'axes')
    ax = arg1;
    if nargin==2
      val = arg2;
    else
      a = get(ax,'projection');
      return
    end
  else
    if nargin==2
      error(message('MATLAB:camproj:WrongNumberArguments'))
    else
      ax = gca;
      val = arg1;
    end
  end
    
  set(ax,'projection',val);
end

if nargout == 1
  a = get(ax,'projection');
end

