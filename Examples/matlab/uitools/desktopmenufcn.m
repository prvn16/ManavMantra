function desktopmenufcn(dtmenu, cmd)
% This function is undocumented and will change in a future release

% DESKTOPMENUFCN Implements the Desktop menu of undocked figure windows.

% Copyright 2003-2017 The MathWorks, Inc.

narginchk(1,2)

if nargin > 1
    cmd = convertStringsToChars(cmd);
end

if ischar(dtmenu)
    cmd = dtmenu;
    dtmenu = gcbo;
end

% But gcbo does not return the correct menu object sometimes when menu's
% CreateFcn is called.  
%
% In the following edge case , this menu item will be enabled
% in the native figure menubar if that figure is created
% without menubar, then javaFigures mode is turned on, and then
% menubar is turned on. In that case, it will be disabled by its
% Callback code in 'desktopmenupopulate' below when clicked.
if ~strcmpi(get(dtmenu, 'Type'), 'uimenu')
    return;
end

fig = get(dtmenu,'Parent');

% possibly related to the above check on dtmenu, it can happen that 
% this callback has a partially defined figure which manifests as a 
% bogus DockControls property value. This happens even without Java
% figures turned on
if ~ischar(get(fig,'DockControls'))
  return;
end

switch lower(cmd)       
    case 'desktopmenupopulate'
        % disable the warning when using the 'JavaFrame' property
        % this is a temporary solution
%      if isempty(get(fig, 'JavaFrame'))
        oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
        jf = get(fig, 'JavaFrame');
        warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
        if isempty(jf)
            delete(allchild(dtmenu));
            set(dtmenu,'Visible','off')
        elseif ishghandle(dtmenu)
            % Java Figures is on and DockControls is on. 
            % This is a Java Figure. So, populate the desktop menu.
            h = allchild(dtmenu);
            if isempty(h)
                h = uimenu(dtmenu);
            end
            set(h,'Tag','figDesktopMenuChild');
            
            name = get(fig, 'Name');
            t = '';
            if strcmp(get(fig,'NumberTitle'),'on')
                t = sprintf('Figure %.8g',double(fig));
                if ~isempty(name)
                    t = [t, ': '];
                end
            end
            title = [t, name];
            
            if (strcmp(get(fig, 'WindowStyle'), 'docked'))
                set(h, 'Label',getString(message('MATLAB:uistring:desktopmenufcn:Undock', title)), 'Callback', ...
                    {@figureDockingHandler, fig, 'off'});
            else
                set(h, 'Label',getString(message('MATLAB:uistring:desktopmenufcn:Dock', title)), 'Callback', ...
                    {@figureDockingHandler, fig, 'on'});
            end

            % Make the menu visible as it may not be by default.
            set(h, 'Visible', 'on');
            if (strcmp(get(fig, 'DockControls'), 'off'))
            % The DockControls property must be on for the 
            % figure to support docking.
                set(h, 'Enable', 'off');
            else
                set(h, 'Enable', 'on');
            end
        end
end


function figureDockingHandler(~, ~, figh, isDock)
if strcmpi(isDock,'on')
    set(figh, 'WindowStyle', 'docked');
else
    set(figh, 'WindowStyle', 'normal');
end
