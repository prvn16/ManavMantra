function grid(arg1, arg2)
%GRID   Grid lines.
%   GRID ON adds major grid lines to the current axes.
%   GRID OFF removes major and minor grid lines from the current axes. 
%   GRID MINOR toggles the minor grid lines of the current axes.
%   GRID, by itself, toggles the major grid lines of the current axes.
%   GRID(AX,...) uses axes AX instead of the current axes.
%
%   GRID sets the XGrid, YGrid, and ZGrid properties of
%   the current axes. If the axes is a polar axes then GRID sets
%   the ThetaGrid and RGrid properties.
%
%   AX.XMinorGrid = 'on' turns on the minor grid.
%
%   See also TITLE, XLABEL, YLABEL, ZLABEL, AXES, PLOT, BOX, POLARAXES.

%   Copyright 1984-2015 The MathWorks, Inc.

% To ensure the correct current handle is taken in all situations.

import matlab.graphics.internal.*;
opt_grid = 0;
if nargin == 0
    ax = gca;
    
    % Chart subclass support
    if isa(ax,'matlab.graphics.chart.Chart')
        grid(ax);
        return
    end
else
    if isempty(arg1)
        opt_grid = lower(arg1);
    end
    if isCharOrString(arg1)
        % string input (check for valid option later)
        if nargin == 2
            error(message('MATLAB:grid:FirstArgAxes'))
        end
        ax = gca;        
        opt_grid = lower(arg1);
        
        % Chart subclass support
        if isa(ax,'matlab.graphics.chart.Chart')
            grid(ax,opt_grid);
            return
        end
    else
        % make sure non string is a scalar handle
        if length(arg1) > 1
            error(message('MATLAB:grid:ScalarHandle'));
        end
        if ~any(isgraphics(arg1,'axes') | isgraphics(arg1,'polaraxes'))
            error(message('MATLAB:grid:FirstArgAxes'));
        end
        ax = arg1;
        
        % check for string option
        if nargin == 2
            opt_grid = lower(arg2);
        end
    end
end

if (isempty(opt_grid))
    error(message('MATLAB:grid:UnknownOption'));
end
names = get(ax,'DimensionNames');
xgrid = [names{1} 'Grid'];
ygrid = [names{2} 'Grid'];
zgrid = [names{3} 'Grid'];
xminorgrid = [names{1} 'MinorGrid'];
yminorgrid = [names{2} 'MinorGrid'];
zminorgrid = [names{3} 'MinorGrid'];

matlab.graphics.internal.markFigure(ax);

%---Check for bypass option
if isappdata(ax,'MWBYPASS_grid')
   mwbypass(ax,'MWBYPASS_grid',opt_grid);

elseif isequal(opt_grid, 0)
    if (strcmp(get(ax,xgrid),'off'))
        set(ax,xgrid,'on');
    else
        set(ax,xgrid,'off');
    end
    if (strcmp(get(ax,ygrid),'off'))
        set(ax,ygrid,'on');
    else
        set(ax,ygrid,'off');
    end
    if hasZProperties(handle(ax))
        if (strcmp(get(ax,zgrid),'off'))
            set(ax,zgrid,'on');
        else
            set(ax,zgrid,'off');
        end
    end
elseif (strcmp(opt_grid, 'minor'))
    if (strcmp(get(ax,xminorgrid),'off'))
        set(ax,xminorgrid,'on');
    else
        set(ax,xminorgrid,'off');
    end
    if (strcmp(get(ax,yminorgrid),'off'))
        set(ax,yminorgrid,'on');
    else
        set(ax,yminorgrid,'off');
    end
    if hasZProperties(handle(ax))
        if (strcmp(get(ax,zminorgrid),'off'))
            set(ax,zminorgrid,'on');
        else
            set(ax,zminorgrid,'off');
        end
    end
elseif (strcmp(opt_grid, 'on'))
    set(ax,xgrid, 'on', ...
           ygrid, 'on');
    if hasZProperties(handle(ax))
        set(ax,zgrid, 'on');
    end
elseif (strcmp(opt_grid, 'off'))
    set(ax,xgrid, 'off', ...
           ygrid, 'off', ...
           xminorgrid, 'off', ...
           yminorgrid, 'off');
    if hasZProperties(handle(ax))
        set(ax,zgrid, 'off');
        set(ax,zminorgrid, 'off');
    end
else
    error(message('MATLAB:grid:UnknownOption'));
end
