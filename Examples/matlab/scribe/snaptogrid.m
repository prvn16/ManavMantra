function grid=snaptogrid(varargin)
%SNAPTOGRID Snap-to-grid moving and resizing.

%   SNAPTOGRID turns snap-to-grid editing on for current figure
%   SNAPTOGRID(FIG) turns snap-to-grid editing on for figure FIG
%   SNAPTOGRID('on') turns snap-to-grid editing on for current figure
%   SNAPTOGRID('off') turns snap-to-grid editing off for current figure
%   SNAPTOGRID(FIG,'on') turns snap-to-grid editing on for figure FIG
%   SNAPTOGRID(FIG,'off') turns snap-to-grid editing off for figure FIG
%   SNAPTOGRID(GRIDSTRUCT) sets grid properties for current figure
%   SNAPTOGRID(FIG,GRIDSTRUCT) sets grid properties for figure FIG
%   GRIDSTRUCT=SNAPTOGRID(...) returns current grid structure for figure
%   GRIDSTRUCT is a structure with the following fields:
%       xspace: x space in pixels between vertical grid lines
%       yspace: y space in pixels between horizontal grid lines
%       visible: set to 'on' to display grid or 'off' to hide it.
%       color: A 1x3 color vector for the grid
%       lineStyle: same as line linestyle strings
%       lineWidth: same as line linewidth
%       influence: Distance in pixels from grid at which an object snaps
%       snapType: Determines the part of the edited object which snaps to the
%       grid. SnapType can be one of the following:
%       'top'
%       'bottom'
%       'left'
%       'right'
%       'center'
%       'topleft' 
%       'topright'
%       'bottomleft'
%       'bottomright'
%   Internal syntax:
%   SNAPTOGRID(FIG,'togglesnap') toggles snap on/off and handles figure menu
%   toggle (check) menu item.
%   SNAPTOGRID(FIG,'toggleview') toggles view grid and handles figure menu
%   toggle (check) menu item.
%   GRIDSTRUCT=SNAPTOGRID(FIG,'noaction') return grid structure without
%   turning snaptogrid on

%   Copyright 1984-2012 The MathWorks, Inc.

narginchk(0,2);

if nargout>0
    returngrid=true;
else
    returngrid=false;
end

if nargin==2
    if isscalar(varargin{1}) && ishghandle(varargin{1},'figure')
        fig = varargin{1};
    else
        error(message('MATLAB:snaptogrid:InvalidFirstFigureHandle'));
    end
    if ischar(varargin{2}) 
        if ~isAction(varargin{2})
            error(message('MATLAB:snaptogrid:InvalidAction'));
        else
            action = varargin{2};
        end
    else
        newgridstruct = varargin{2};
        action = 'setgrid';
    end
elseif nargin==1
    if isscalar(varargin{1}) && (ishandle(varargin{1}) || isobject(varargin{1}))
        if ishghandle(varargin{1},'figure')
            fig = varargin{1};
            action = 'on';
        else
            error(message('MATLAB:snaptogrid:InvalidFigureHandle'));
        end
    elseif ischar(varargin{1})
        fig = figcheck;
        if ~isAction(varargin{1})
            error(message('MATLAB:snaptogrid:InvalidOnOff'));
        else
            action = varargin{1};
        end
    else
        fig = figcheck;
        newgridstruct = varargin{1};
        action = 'setgrid';
    end
else
    fig = figcheck;
    action = 'on';
end

switch action
    case 'on'
        ison = getappdata(fig,'scribegui_snaptogrid');
        if isempty(ison) || ~strcmpi(ison,'on')
            setappdata(fig,'scribegui_snaptogrid','on');
            if isappdata(fig,'scribegui_snapgridstruct')
                oldgridstruct=getappdata(fig,'scribegui_snapgridstruct');
                oldgridstruct=fill_in_gridstruct(oldgridstruct,fig);
                update_scribegrid(oldgridstruct,fig);
            else
                newgridstruct=set_default_gridstruct(fig);
                update_scribegrid(newgridstruct,fig);
            end
        end
    case 'off'
        ison = getappdata(fig,'scribegui_snaptogrid');
        if isempty(ison) || ~strcmpi(ison,'off')
            setappdata(fig,'scribegui_snaptogrid','off');
            if isappdata(fig,'scribegui_snapgridstruct')
                oldgridstruct=getappdata(fig,'scribegui_snapgridstruct');
                oldgridstruct=fill_in_gridstruct(oldgridstruct,fig);
                update_scribegrid(oldgridstruct,fig);
            else
                newgridstruct=set_default_gridstruct(fig);
                update_scribegrid(newgridstruct,fig);
            end
        end
    case 'togglesnap'
        t = findall(fig,'tag','figMenuSnapToGrid');
        checked = get(t,'checked');
        if strcmpi(checked,'off')
            set(t,'checked','on');
            snaptogrid(fig,'on');
        else
            set(t,'checked','off');
            snaptogrid(fig,'off');
        end
    case 'toggleview'
        t = findall(fig,'tag','figMenuViewGrid');
        checked = get(t,'checked');
        g=snaptogrid(fig,'noaction');
        if strcmpi(checked,'off')
            set(t,'checked','on');
            g.Visible='on';
        else
            set(t,'checked','off');
            g.Visible='off';
        end
        snaptogrid(fig,g);
    case 'noaction'
        % do nothing
    case 'setgrid'
        newgridstruct=fill_in_gridstruct(newgridstruct,fig);
        update_scribegrid(newgridstruct,fig);
end

if returngrid
    if isappdata(fig,'scribegui_snapgridstruct')
        grid = getappdata(fig,'scribegui_snapgridstruct');
        grid = fill_in_gridstruct(grid,fig);
    else
        grid = set_default_gridstruct(fig);
    end
end

%------------------------------------------------------------------------%
function grid=set_default_gridstruct(fig)
% could call fill_in_gridstruct with empty struct...
% create default grid structure
grid.xspace = 20;
grid.yspace = 20;
grid.Visible = 'off';
grid.color = best_grid_color(fig);
grid.lineStyle = '-';
grid.lineWidth = 1.0;
grid.influence = 10;
grid.snapType = 'topleft';
setappdata(fig,'scribegui_snapgridstruct',grid);

%------------------------------------------------------------------------%
function newgrid=fill_in_gridstruct(oldgrid,fig)
% fill in any missing fields and save
needsset = false;
newgrid=oldgrid;
if ~isfield(oldgrid,'xspace'), newgrid.xspace = 20; needsset=true; end
if ~isfield(oldgrid,'yspace'), newgrid.yspace = 20; needsset=true; end
if ~isfield(oldgrid,'Visible'), newgrid.Visible = 'off'; needsset=true; end
if ~isfield(oldgrid,'color'), newgrid.color = best_grid_color(fig); needsset=true; end
if ~isfield(oldgrid,'lineStyle'), newgrid.lineStyle = '-'; needsset=true; end
if ~isfield(oldgrid,'lineWidth'), newgrid.lineWidth = 1.0; needsset=true; end
if ~isfield(oldgrid,'influence'), newgrid.influence = 10; needsset=true; end
if ~isfield(oldgrid,'snapType'), newgrid.snapType = 'topleft'; needsset=true; end
if needsset, setappdata(fig,'scribegui_snapgridstruct',newgrid); end

%-----------------------------------------------------------------------%
function fig=figcheck
if length(findobj(0,'type','figure'))<1
    error(message('MATLAB:snaptogrid:NoFigures'));
end
fig = get(0,'currentfigure');

%-----------------------------------------------------------------------%
function update_scribegrid(gridstruct,fig)

SG = findScribeGrid(fig);

%set appdata
setappdata(fig,'scribegui_snapgridstruct',gridstruct);
copy_struct_to_scribegrid(gridstruct,SG);

%-----------------------------------------------------------------------%
function copy_struct_to_scribegrid(gridstruct,SG)

SG.XSpace = gridstruct.xspace;
SG.YSpace = gridstruct.yspace;
SG.Visible = gridstruct.Visible;
SG.Color = gridstruct.color;
SG.LineStyle = gridstruct.lineStyle;
SG.LineWidth = gridstruct.lineWidth;

%-----------------------------------------------------------------------%
function gcolor=best_grid_color(fig)

figcolor=get(fig,'color');
if abs(figcolor(1) - figcolor(2)) < 0.07 && ...
        abs(figcolor(2) - figcolor(3)) < 0.07
    % more or less grey
    if figcolor(1) < 0.5
        gcolor = [figcolor(1) + .3, figcolor(2) + .3, figcolor(3) + .3];
    else
        gcolor = [figcolor(1) - .3, figcolor(2) - .3, figcolor(3) - .3];
    end
else
    % not really grey
    gcolor = [0 0 0];
    lessFive = figcolor < .5;
    gcolor(lessFive) = figcolor(lessFive) + .3;
    gcolor(~lessFive) = figcolor(~lessFive) - .3;
end

% check for over/underflow
gcolor(gcolor<0) = 0;
gcolor(gcolor>1) = 1;


function y = isAction(str)
y = any(strcmpi(str,{'on','off','togglesnap','toggleview','noaction'}));
