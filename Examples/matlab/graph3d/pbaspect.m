function a = pbaspect(arg1, arg2)
%PBASPECT Plot box aspect ratio.
%   PBAR = PBASPECT             gets the plot box aspect ratio of the
%                                  current axes.
%   PBASPECT([X Y Z])           sets the plot box aspect ratio.
%   PBARMODE = PBASPECT('mode') gets the plot box aspect ratio mode.
%   PBASPECT(mode)              sets the plot box aspect ratio mode.
%                                  (mode can be 'auto' or 'manual')
%   PBASPECT(AX,...)            uses axes AX instead of current axes.
%
%   PBASPECT sets or gets the PlotBoxAspectRatio or
%   PlotBoxAspectRatioMode property of an axes.
%
%   See also DASPECT, XLIM, YLIM, ZLIM.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 0
    arg1 = convertStringsToChars(arg1);
end

if nargin > 1
    arg2 = convertStringsToChars(arg2);
end

if nargin == 0
    a = get(gca,'plotboxaspectratio');
else
    if length(arg1)==1 && ishghandle(arg1,'axes')
        ax = arg1;
        if nargin==2
            val = arg2;
        else
            a = get(ax,'plotboxaspectratio');
            return
        end
    else
        if nargin==2
            error(message('MATLAB:pbaspect:InvalidNumberArguments'))
        else
            ax = gca;
            val = arg1;
        end
    end

    if ischar(val)
        if(strcmp(val,'mode'))
            a = get(ax,'plotboxaspectratiomode');
        else
            set(ax,'plotboxaspectratiomode',val);
        end
    else
        set(ax,'plotboxaspectratio',val);
    end
end
