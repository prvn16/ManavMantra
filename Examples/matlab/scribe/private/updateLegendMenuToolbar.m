function updateLegendMenuToolbar(hProp,eventData,hObj) %#ok
%updateLegendMenuToolbar Update menu and toolbar controls for legend and colorbar

%   Copyright 2011-2014 The MathWorks, Inc.

% determine which figure and axes are interested in
if ~isempty(eventData)
    fig = eventData.AffectedObject;
else
    fig = ancestor(hObj,'figure');    
end

%bail out early, if the figure cannot be found
if(isempty(fig))
   return 
end

cax = fig.CurrentAxes;

% update controls only for default figure menubar or toolbar
% figure Toolbar == 'auto' follows the value of figure Menubar
% Also, we can leave early if the figure is being deleted, which could
% cause the CurrentAxes listener to fire (see below)
if ~(strcmp(fig.MenuBar,'figure') || strcmp(fig.ToolBar,'figure'))
    return
elseif strcmp(fig.BeingDeleted,'on')
    return
end

% create MenuToolbarInfo object and store in a transient, hidden
% dynamic prop on the figure.
if ~isprop(fig,'LegendColorbarMenuToolbarInfo')
    hP = addprop(fig,'LegendColorbarMenuToolbarInfo');
    hP.Hidden = true;
    hP.Transient = true;
    fig.LegendColorbarMenuToolbarInfo = matlab.graphics.illustration.internal.MenuToolbarInfo(fig);
    hP.SetAccess = 'private';
end


% determine which menubar/toolbar to update
updateMenubar = false;
updateToolbar = false;
if strcmp(fig.MenuBar,'figure')
    updateMenubar = true;
    if strcmp(fig.ToolBar,'auto')
        updateToolbar = true;
    end
end
if strcmp(fig.ToolBar,'figure')
    updateToolbar = true;
end

% check if legend is on for the current axes
legon = false;
if ~isempty(cax) && isvalid(cax)
    % Check for a 'LegendVisible' property first (for charts that expose
    % a LegendVisible property)
    if isprop(cax,'LegendVisible')
        legon = strcmp(cax.LegendVisible,'on');
    elseif isprop(cax,'Legend')
        if isValidLegendHandleObject(cax.Legend)
            legon = true;
        else
            % An HG1 fig file may contain a double handle to a deleted legend
            % If so, clear the property.  This axes has no legend.
            cax.setLegendExternal([]);
        end
    end
end

% check if colorbar is on for the current axes
cbaron = false;
if ~isempty(cax) && isvalid(cax)
    % Check for a 'ColorbarVisible' property first (for charts that expose
    % a ColorbarVisible property)
    if isprop(cax,'ColorbarVisible')
        cbaron = strcmp(cax.ColorbarVisible,'on');
    elseif isprop(cax,'Colorbar')
        if isValidColorBarHandleObject(cax.Colorbar)
            cbaron = true;
        else
            % An HG1 fig file may contain a double handle to a deleted colorbar
            % If so, clear the property.  This axes has no colorbar.
            cax.setColorbarExternal([]);
        end
    end
end

info = fig.LegendColorbarMenuToolbarInfo;

if updateMenubar
    if isempty(info.LegendMenu)
        info.LegendMenu = findall(fig,'Tag','figMenuInsertLegend');
    end
    if isempty(info.ColorbarMenu)
        info.ColorbarMenu = findall(fig,'Tag','figMenuInsertColorbar');
    end

    lmenu = info.LegendMenu;
    if ~isempty(lmenu) && isvalid(lmenu)
        if legon
            lmenu.Checked = 'on';
        else
            lmenu.Checked = 'off';
        end
    end

    cbmenu = info.ColorbarMenu;
    if ~isempty(cbmenu) && isvalid(cbmenu)
        if cbaron
            cbmenu.Checked = 'on';
        else
            cbmenu.Checked = 'off';
        end
    end
end

if updateToolbar
    if isempty(info.LegendToggle)
        info.LegendToggle = uigettool(fig,'Annotation.InsertLegend');
    end
    if isempty(info.ColorbarToggle)
        info.ColorbarToggle = uigettool(fig,'Annotation.InsertColorbar');
    end

    ltoggle = info.LegendToggle;
    if ~isempty(ltoggle) && isvalid(ltoggle)
        if legon
            ltoggle.State = 'on';
        else
            ltoggle.State = 'off';
        end
    end

    cbtoggle = info.ColorbarToggle;
    if ~isempty(cbtoggle) && isvalid(cbtoggle)
        if cbaron
            cbtoggle.State = 'on';
        else
            cbtoggle.State = 'off';
        end
    end
end

function tf = isValidLegendHandleObject(leg)
% return true if leg is a valid MCOS Legend
tf = false;
leg = handle(leg);
isaLegend = isa(leg,'matlab.graphics.illustration.Legend');
if isaLegend && isvalid(leg) && strcmp(leg.BeingDeleted,'off')
    tf = true;
end

function tf = isValidColorBarHandleObject(cbar)
% return true if leg is a valid MCOS ColorBar
tf = false;
cbar = handle(cbar);
isaColorBar = isa(cbar,'matlab.graphics.illustration.ColorBar');
if isaColorBar && isvalid(cbar) && strcmp(cbar.BeingDeleted,'off')
    tf = true;
end
