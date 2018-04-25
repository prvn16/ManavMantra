function plottools (varargin)
% PLOTTOOLS  Show or hide the plot-editing tools for a figure.
%    PLOTTOOLS ON shows the tools for the current figure.
%    PLOTTOOLS OFF hides the tools.
%    PLOTTOOLS TOGGLE toggles the visibility of the tools.
%    PLOTTOOLS with no arguments is the same as ON.
%
% Some plotting tools may not appear when you activate plottools.  Only
% those tools that were visible the last time you used them will be shown.
% For example, if you were only using the Property Editor most recently,
% only the Property Editor will be shown when you type "plottools on" or
% activate the plot tools from the toolbar.  You can then show the rest by
% using the "View" or "Desktop" menu, or by using the commands listed
% below.
%
% The first argument may be the handle to a figure, like so:
%    PLOTTOOLS (h, 'on')
%
% The last argument may be the name of a specific component, like so:
%    PLOTTOOLS ('on', 'figurepalette') or
%    PLOTTOOLS (h, 'on', 'figurepalette')
% The available components are named 'figurepalette', 'plotbrowser',
% and 'propertyeditor'.
%
% See also FIGUREPALETTE, PLOTBROWSER, and PROPERTYEDITOR.

%   Copyright 1984-2017 The MathWorks, Inc.



% plottools ('on')
% plottools ('on', 'figurepalette')
% plottools (h, 'on', 'figurepalette')
% plottools (h, 'on')
% plottools (h, 'on', 'figurepalette')


narginchk (0,3)

if ispref('plottools', 'isdesktop')
    rmpref('plottools', 'isdesktop');
end

% Defaults:
fig = [];
action = 'on';
comp = 'all';

% Constants:
GROUPNAME = 'Figures';

% Use the arguments:
if nargin == 1
    if isscalar(varargin{1}) && ishghandle (varargin{1})
        fig = varargin{1};
    elseif ischar(varargin{1}) || isstring(varargin{1})
        action = varargin{1};
    else
        error(message('MATLAB:plottools:invalidhandle'));
    end
elseif nargin == 2         % either (h, 'on') or ('on', 'panel')
    if isscalar(varargin{1}) && ishghandle (varargin{1})
        fig = varargin{1};
        action = varargin{2};
    elseif ischar(varargin{1}) || isstring(varargin{1})
        action = varargin{1};
        if isstring(varargin{2})
            comp = char(varargin{2});
        else
            comp = varargin{2};
        end
    else
        error(message('MATLAB:plottools:invalidhandle'));
    end
elseif nargin == 3
    if isscalar(varargin{1}) && ishghandle (varargin{1})
        fig = varargin{1};
        action = varargin{2};
        comp = varargin{3};
    else
        error(message('MATLAB:plottools:invalidhandle'));
    end
end

if ~isempty(fig) && ~usejava('Swing')
    error(message('MATLAB:plottools:UnsupportedPlatform'));
end

% Do nothing if the figure is really a dialog:
if ~isempty(fig)
    if strncmpi (get(handle(fig),'Tag'), 'Msgbox', 6) || ...
            strcmpi (get(handle(fig),'WindowStyle'), 'Modal')
        return
    end
end

if isempty(fig)
    fig = gcf;
    
    % create the Figure's submenu peers so accelerator keys
    % work before the top level menu is enabled (g852044)
    matlab.ui.internal.createMenuPeers(fig)
    
    if ~com.mathworks.page.plottool.WaitBar.hasOpened
        % Make sure any figure closing events have been processed before
        % attempting to dock the figure into the Plot Tools for the
        % first time. This avoids race conditions where a figure closes
        % during the initial plot tools creation (which can be slow).
        drawnow
        if ishghandle(fig) && strcmp(get(fig,'BeingDeleted'),'off')
            com.mathworks.page.plottool.WaitBar.open(get(fig,'Position'),...
                java(handle(fig)));
            % Early initialize propertyinspector while waitbar is opened
            matlab.graphics.internal.propertyinspector.propertyinspector('initInspector');
        else
            return
        end
    end
    
    
    % "If all, and you're showing stuff (esp if no args), do this."
    if (strcmp (comp, 'all') ~= 0) &&  desktop('-inuse') && ...
            (nargin == 0 || (strcmp (action, 'on') ~= 0) ...
            || (strcmp (action, 'show') ~= 0))
        
        dt=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
        
        % If plot tools are not being displayed, restore the last layout
        % saved to the profile directory.
        if ~dt.isGroupShowing(GROUPNAME)
            dt.restoreGroupSingletons(GROUPNAME);
            
            % Push plot tools to the front if at least one component is
            % already being displayed.
        else
            if ~dt.isClientShowing ('Figure Palette', GROUPNAME) && ...
                    ~dt.isClientShowing ('Plot Browser', GROUPNAME) && ...
                    ~dt.isClientShowing ('Property Editor', GROUPNAME)
                dt.restoreGroupSingletons(GROUPNAME);
            else
                jf = dt.getFrameContainingGroup(GROUPNAME);
                if ~isempty(jf)
                    awtinvoke(jf,'toFront');
                end
            end
        end
        
        set (fig, 'WindowStyle', 'docked');
        enableplottoolbuttons (fig)
        % Make sure java has finished or subsequent figure closing
        % may not update the PlotTools (c.f. 343133)
        drawnow
        return;
    end
else
    % create the Figure's submenu peers so accelerator keys
    % work before the top level menu is enabled (g852044)
    matlab.ui.internal.createMenuPeers(fig)
    
    if ~com.mathworks.page.plottool.WaitBar.hasOpened
        % Make sure any figure closing events have been processed before
        % attempting to dock the figure into the Plot Tools for the
        % first time. This avoids race conditions where a figure closes
        % during the initial plot tools creation (which can be slow).
        drawnow
        if ishghandle(fig) && strcmp(get(fig,'BeingDeleted'),'off')
            com.mathworks.page.plottool.WaitBar.open(get(fig,'Position'),...
                java(handle(fig)));
            % Early initialize propertyinspector while waitbar is opened
            matlab.graphics.internal.propertyinspector.propertyinspector('initInspector');
        else
            return
        end
    end
end



% If we're only showing/hiding one of the plot tools, we might
% as well just call showplottool.  It'll do all the right things.
if (strcmp (comp, 'all') == 0)
    showplottool (fig, action, comp);
    % Make sure java has finished or subsequent figure closing
    % may not update the PlotTools
    drawnow
    return;
end

% Find the correct group name:
jf = javaGetFigureFrame(fig);
if ~isempty(jf)
    groupName = jf.getGroupName;
    dt = jf.getDesktop;  % doesn't this come from the figure peer?
else
    groupName = GROUPNAME;
    dt=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
end

% Figure out if 'toggle' means 'on' or 'off':
if (strcmp (action, 'toggle') ~= 0)
    if dt.isClientShowing ('Figure Palette', groupName) || ...
            dt.isClientShowing ('Plot Browser', groupName) || ...
            dt.isClientShowing ('Property Editor', groupName)
        action = 'off';
    else
        action = 'on';
    end
end


% Do it:
switch lower(action)
    case {'on', 'show'}
        localEnablePlotEdit(fig);
        %----
        com.mathworks.page.plottool.FigurePalette.addAsDesktopClient(dt,groupName);
        com.mathworks.page.plottool.PlotBrowser.addAsDesktopClient(dt,groupName);
        com.mathworks.page.plottool.PropertyEditor.addAsDesktopClient(dt,groupName);
        
        %----
        % Play docking games.
        figureGroupShowing = dt.isGroupShowing (groupName);
        if ~figureGroupShowing
            dt.showGroup(groupName,false);
            dt.setGroupDocked (groupName, false);
        end
        set (fig, 'WindowStyle', 'docked');
        dt.restoreGroupSingletons (groupName);
        enableplottoolbuttons (fig)
    case {'off', 'hide'}
        plotedit(fig,'off');
        dt.closeGroupSingletons (groupName);
        enableplottoolbuttons (fig)
        com.mathworks.page.plottool.WaitBar.close;
        % If there's one figure in the group, undock figure and close group.
        % (note: is this desired behavior for timeseries tools also?)
        %     allFigs = dt.getGroupMembers (groupName);
        %     figCount = 0;
        %     for i = 1:allFigs.length
        %         if ~dt.isClientDocked (allFigs(i))
        %             continue;
        %         end
        %         javaStr = allFigs(i).getClass.getName;
        %         mStr = char(javaStr);
        %         if ~isempty (strfind(mStr, 'FigureDTClientBase'))
        %             figCount = figCount + 1;
        %         end
        %     end
        %     if figCount == 1
        %         set (fig, 'WindowStyle', 'normal');
        %         drawnow;
        %         dt.closeGroup (groupName, true, true);
        %     end
    otherwise
        com.mathworks.page.plottool.WaitBar.close;
        error(message('MATLAB:plottools:InvalidPlotToolsState'))
end

%------------------------------------------------------------------------%
function localEnablePlotEdit(hFig)
% Enable plot edit mode only if the plot edit toolbar button is present
% See g327324

behavePlotEdit = hggetbehavior(hFig,'PlotTools','-peek');
if isempty(behavePlotEdit) || behavePlotEdit.ActivatePlotEditOnOpen
    plotedit(hFig,'on');
end