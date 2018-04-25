function [azOut, elOut] = lightangle(h, az, el)
%LIGHTANGLE Spherical position of a light.
%   LIGHTANGLE(AZ, EL)      creates a light in the current axes at the
%                           specified position.
%   H = LIGHTANGLE(AZ, EL)  creates a light and returns its handle.
%   LIGHTANGLE(H, AZ, EL)   sets the position of the specified light.
%   H = LIGHTANGLE(AX, AZ, EL)  creates a light in the specified axes and
%                           returns its handle.
%   [AZ EL] = LIGHTANGLE(H) gets the position of the specified light.
%
%   LIGHTANGLE creates or positions a light using azimuth and
%   elevation.  AZ is the azimuth or horizontal rotation and EL is the
%   vertical elevation (both in degrees).  The interpretation of azimuth
%   and elevation are exactly the same as with the VIEW command.
%   When a light is created, its style is 'infinite'.  If the light
%   passed into lightangle is a local light, the distance between the
%   light and the camera target is preserved.
%
%   See also LIGHT, CAMLIGHT, LIGHTING, MATERIAL, VIEW.

%   Copyright 1984-2017 The MathWorks, Inc.

ax = gobjects(0);
getting = false;
if nargin > 3 || nargin < 1
    error(message('MATLAB:lightangle:WrongNumberArguments'))
elseif nargin == 2
    % h = lightangle(az, el)
    el = az;
    az = h;
    h = gobjects(0);
elseif isscalar(h) && isgraphics(h, 'light')
    % [az, el] = lightangle(h) or h = lightangle(h, az, el)
    ax = ancestor(h, 'axes');
    getting = (nargin == 1);
elseif isscalar(h) && isgraphics(h, 'axes')
    % h = lightangle(ax, az, el)
    assert(nargin == 3, message('MATLAB:lightangle:WrongNumberArguments'));
    ax = h;
    h = gobjects(0);
else
    error(message('MATLAB:lightangle:MustBeHandle'))
end

if ~getting && nargout>1
    % Only one output argument (h) is allowed unless you are querying the
    % current azimuth and elevation from an existing light.
    error(message('MATLAB:lightangle:InvalidNumberOutput'))
end

if isempty(ax)
    % No Axes specifies, use GCA.
    ax = gca;
end

if isempty(h)
    % No light specified, create a new light in the specified axes.
    h = light(ax);
end

ct  = ax.CameraTarget;
dar = ax.DataAspectRatio;

if strcmp(get(h, 'style'), 'local')
    dif = (h.Position-ct)./dar;
else
    dif =  h.Position./dar;
end

dis = norm(dif);

if getting % getting the azimuth and elevation from existing handle.
    rad2deg = 180/pi;
    azOut = atan2(dif(2),dif(1))+pi/2;
    elOut = asin( dif(3)/dis );
    azOut = azOut*rad2deg;
    elOut = elOut*rad2deg;
else % setting the azimuth and elevation
    if ~isnumeric([az el]) || length(az) > 1 || length(el) > 1
        error(message('MATLAB:lightangle:InputsMustBeScalar'))
    end
    deg2rad = pi/180;
    az = az*deg2rad;
    
    if mod(el-90,180)==0
        newPos = [0 0 sin(el)];
    else
        el = el*deg2rad;
        newPos = [sin(az)*cos(el) -cos(az)*cos(el) sin(el)];
    end
    
    if strcmp(h.Style, 'local')
        pos = ct+newPos*dis.*dar;
    else
        pos = newPos*dis.*dar;
    end
    
    h.Position = pos;
    if nargout==1
        azOut = h;
    end
end

