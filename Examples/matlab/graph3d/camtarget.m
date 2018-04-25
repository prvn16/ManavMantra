function a = camtarget(arg1, arg2)
%CAMTARGET Camera target.
%   CT = CAMTARGET             gets the camera target of the current
%                                 axes.
%   CAMTARGET([X Y Z])         sets the camera target.
%   CTMODE = CAMTARGET('mode') gets the camera target mode.
%   CAMTARGET(mode)            sets the camera target mode.
%                                 (mode can be 'auto' or 'manual')
%   CAMTARGET(AX,...)          uses axes AX instead of current axes.
%
%   CAMTARGET sets or gets the CameraTarget or CameraTargetMode
%   property of an axes.
%
%   See also CAMPOS, CAMVA, CAMPROJ, CAMUP.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 0
    arg1 = convertStringsToChars(arg1);
end

if nargin > 1
    arg2 = convertStringsToChars(arg2);
end

if nargin == 0
    a = get(gca,'cameratarget');
else
    if length(arg1)==1 && ishghandle(arg1,'axes')
        ax = arg1;
        if nargin==2
            val = arg2;
        else
            a = get(ax,'cameratarget');
            return
        end
    else
        if nargin==2
            error(message('MATLAB:camtarget:WrongNumberArguments'))
        else
            ax = gca;
            val = arg1;
        end
    end

    if ischar(val)
        if(strcmp(val,'mode'))
            a = get(ax,'cameratargetmode');
        else
            set(ax,'cameratargetmode',val);
        end
    else
        set(ax,'cameratarget',val);
    end
end

