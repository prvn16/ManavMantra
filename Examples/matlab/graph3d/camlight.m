function ret = camlight(varargin)
%CAMLIGHT Create or set position of a light.
%   CAMLIGHT HEADLIGHT creates a light in the current axes at the
%                         camera position of the current axes.
%   CAMLIGHT RIGHT     creates a light right and up from camera.
%   CAMLIGHT LEFT      creates a light left and up from camera.
%   CAMLIGHT           same as CAMLIGHT RIGHT.
%   CAMLIGHT(AZ, EL)   creates a light at AZ, EL from camera.
%
%   CAMLIGHT(..., style) set the style of the light.
%                 Style can be 'local' (default) or 'infinite'.
%
%   CAMLIGHT(H, ...)   places specified light at specified position.
%   CAMLIGHT(AX, ...)   places a new light in the specified axes.
%   H = CAMLIGHT(...)  returns light handle.
%
%   CAMLIGHT creates or positions a light in the coordinate system of
%   the camera. For example, if both AZ and EL are zero, the light
%   will be placed at the camera's position.  In order for a light
%   created with CAMLIGHT to stay in a constant position relative to
%   the camera, CAMLIGHT must be called whenever the camera is moved.
%
%   See also LIGHT, LIGHTANGLE, LIGHTING, MATERIAL, CAMORBIT.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

defaultAz = 30;
defaultEl = 30;
defaultStyle = 'local';
ax = gobjects(0);
h = gobjects(0);

if nargin>4
    error(message('MATLAB:camlight:TooManyInputs'))
else
    args = varargin;
    
    % Check the first input argument for either a light or axes handle.
    if ~isempty(args) && isscalar(args{1})
        if isgraphics(args{1},'axes')
            % Axes handle detected, create a light in that axes.
            % camlight(ax, ...)
            ax = args{1};
            args(1) = [];
        elseif isgraphics(args{1},'light')
            % Light handle detected, use that light and the ancestor axes.
            % camlight(light, ...)
            h = args{1};
            ax = ancestor(h, 'axes');
            args(1) = [];
        end
    end
    
    % Check for either 'local' or 'infinite' as the last input argument.
    if ~isempty(args) && validString(args{end})==2
        % Style input found.
        % camlight(..., 'local') or camlight(..., 'infinite')
        style = args{end};
        args(end) = [];
    else
        % Use the default style.
        style = defaultStyle;
    end
    
    % Check for azimuth and elevation in the remaining arguments.
    len = length(args);
    if len > 2
        % Too many input arguments.
        error(message('MATLAB:camlight:InvalidNumberOfArguments'));
    elseif len == 1
        % One input argument.
        % camlight('headlight') or camlight('left') or camlight('right')
        [c, az, el] = validString(args{1});
        if c~=1 && matlab.graphics.internal.isCharOrString(args{1})
            % Invalid character vector.
            error(message('MATLAB:camlight:InvalidArgument', args{1}));
        elseif c~=1
            % Input was not a character vector.
            error(message('MATLAB:camlight:InvalidNumberOfArguments'));
        end
    elseif len==2
        % Two input arguments.
        % camlight(azumuth,elevation)
        az = args{1};
        el = args{2};
        if ~(isnumeric(az) && isscalar(az) && isnumeric(el) && isscalar(el))
            error(message('MATLAB:camlight:InvalidNumberOfArguments'));
        elseif ~(isreal(az) && isreal(el))
            error(message('MATLAB:camlight:NotValidArguments',num2str(az),num2str(el)));
        end
    else
        az = defaultAz; el = defaultEl;
    end
end

if isempty(ax)
    % Use GCA (or create new axes).
    ax = gca;
end
if isempty(h)
    % Create a new light in the specified axes.
    h = light(ax);
end

pos  = get(ax, 'cameraposition' );
targ = get(ax, 'cameratarget'   );
dar  = get(ax, 'dataaspectratio');
up   = get(ax, 'cameraupvector' );

if ~righthanded(ax), az = -az; end

newPos = camrotate(pos,targ,dar,up,az,el,'camera',[]);

if style(1)=='i'
    newPos = newPos-targ;
    newPos = newPos/norm(newPos);
end
set(h, 'position', newPos, 'style', style);

if nargout>0
    ret = h;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret, az, el]= validString(str)

defaultAz = 30;
defaultEl = 30;
az = 0; el = 0;

if matlab.graphics.internal.isCharOrString(str)
    % Convert from string to character vector.
    str = char(str);
    
    if isempty(str)
        ret = 0;
        return
    end
    
    c1 = lower(str(1));
    
    if length(str)>1
        c2 = lower(str(2));
    else
        c2 = [];
    end
    
    if c1=='r'        %right
        ret = 1;
        az = defaultAz; el = defaultEl;
    elseif c1=='h'    %headlight
        ret = 1;
        az = 0; el = 0;
    elseif c1=='i'    %infinite
        ret = 2;
    elseif c1=='l' && ~isempty(c2)
        if c2=='o'      %local
            ret = 2;
        elseif c2=='e'  %left
            ret = 1;
            az = -defaultAz; el = defaultEl;
        else
            ret = 0;
        end
    else
        ret = 0;
    end
else
    ret = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val=righthanded(ax)

dirs=get(ax, {'xdir' 'ydir' 'zdir'});
num=length(find(lower(cat(2,dirs{:}))=='n'));

val = mod(num,2);
