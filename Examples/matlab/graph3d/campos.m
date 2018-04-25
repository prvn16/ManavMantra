function a = campos(arg1, arg2)
%CAMPOS Camera position.
%   CP = CAMPOS              gets the camera position of the current
%                               axes.
%   CAMPOS([X Y Z])          sets the camera position.
%   CPMODE = CAMPOS('mode')  gets the camera position mode.
%   CAMPOS(mode)             sets the camera position mode.
%                               (mode can be 'auto' or 'manual')
%   CAMPOS(AX,...)           uses axes AX instead of current axes.
%
%   CAMPOS sets or gets the CameraPosition or CameraPositionMode
%   property of an axes.
%
%   See also CAMTARGET, CAMVA, CAMPROJ, CAMUP.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 0
    arg1 = convertStringsToChars(arg1);
end

if nargin > 1
    arg2 = convertStringsToChars(arg2);
end

if nargin == 0
    a = get(gca,'cameraposition');
else
    if length(arg1)==1 && ishghandle(arg1,'axes')
        ax = arg1;
        if nargin==2
            val = arg2;
        else
            a = get(ax,'cameraposition');
            return
        end
    else
        if nargin==2
            error(message('MATLAB:campos:WrongNumberArguments'))
        else
            ax = gca;
            val = arg1;
        end
    end

    if ischar(val)
        if(strcmp(val,'mode'))
            a = get(ax,'camerapositionmode');
        else
            set(ax,'camerapositionmode',val);
        end
    else
        set(ax,'cameraposition',val);
    end
end

