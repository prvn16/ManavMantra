function uirestore(uistate,kidsOnly)
% This function is undocumented and will change in a future release

%UIRESTORE Restores the interactive functionality figure window.
%   UIRESTORE(UISTATE) restores the state of a figure window to
%   what it was before it was suspended by a call to UISUSPEND.
%   The input UISTATE is the structure returned by UISUSPEND which
%   contains information about the window properties and the button
%   down functions for all of the objects in the figure.
%
%   UIRESTORE(UISTATE, 'children') updates ONLY the children of
%   the figure.
%
%   UIRESTORE(UISTATE, 'nochildren') updates ONLY the figure.
%
%   UIRESTORE(UISTATE, 'uicontrols') updates ONLY the uicontrol children
%   of the figure
%
%   UIRESTORE(UISTATE, 'nouicontrols') updates the figure and all non-uicontrol
%   children of the figure
%
%   Example:
%       fig = figure();
%       fig.Pointer = 'fullcrosshair';
%       state = uisuspend(fig)
%       uirestore(state);
%
%   See also UISUSPEND.

%   Copyright 1984-2014 The MathWorks, Inc.

    fig = uistate.figureHandle;

    % No need to restore anything if the figure isn't there
    if ~ishandle(fig)
        return
    end
    % No need to restore if the figure is being deleted
    if strcmp('on',get(fig,'BeingDeleted'))
        return
    end

    updateFigure   = 1;
    updateChildren = 1;
    updateUICtrl   = 1;

    if nargin == 2
        if strcmpi(kidsOnly, 'children')
            updateFigure   = 0;
        elseif strcmpi(kidsOnly, 'nochildren')
            updateChildren = 0;
            updateUICtrl   = 0;
        elseif strcmpi(kidsOnly,'uicontrols')
            updateChildren = 0;
        elseif strcmpi(kidsOnly,'nouicontrols')
            updateUICtrl   = 0;
        end
    end

    if ~isempty(uistate.ploteditEnable)
        plotedit(fig, 'setenabletools',uistate.ploteditEnable);
        % Set some app data to inform calling tools that we are in a
        % non-interruptable state:
        if isappdata(fig,'UISuspendActive')
            rmappdata(fig,'UISuspendActive');
        end
    end

    if updateFigure
        set(fig, 'WindowButtonMotionFcn', uistate.WindowButtonMotionFcn)
        set(fig, 'WindowButtonDownFcn',   uistate.WindowButtonDownFcn)
        set(fig, 'WindowButtonUpFcn',     uistate.WindowButtonUpFcn);
        set(fig, 'WindowScrollWheelFcn',  uistate.WindowScrollWheelFcn)
        set(fig, 'WindowKeyPressFcn',     uistate.WindowKeyPressFcn)
        set(fig, 'WindowKeyReleaseFcn',   uistate.WindowKeyReleaseFcn)
        set(fig, 'KeyPressFcn',           uistate.KeyPressFcn)
        set(fig, 'Pointer',               uistate.Pointer)
        set(fig, 'PointerShapeCData',     uistate.PointerShapeCData)
        set(fig, 'PointerShapeHotSpot',   uistate.PointerShapeHotSpot)

        if isfield(uistate,'docontext') && uistate.docontext
            % Do not set an invalid handle or a handle that belongs
            % to another figure. g239172
            if isempty(uistate.UIContextMenu{1}) || ...
                ( ishandle(uistate.UIContextMenu{1}) && ...
                  isequal(fig,ancestor(uistate.UIContextMenu{1},'figure') ))
                set(fig,'UIContextMenu',      uistate.UIContextMenu{1});
            end
        end
    end

    if updateChildren && updateUICtrl
        % updating children including uicontrols
        LupdateChildren(uistate, [], []);
    elseif updateChildren
        % updating non-uicontol children only
        LupdateChildren(uistate, 'uicontrol', false);
    elseif updateUICtrl
        % updating only uicontrol children
        LupdateChildren(uistate, 'uicontrol', true);
    end

end

%----------------------------------------------------
function LupdateChildren(uistate, childType, include)
    fig = [];
    for i=1:length(uistate.Children)
        chi = uistate.Children(i);
        if ~ishandle(chi)
            continue;
        end
        if isempty(fig) || ~ishandle(fig)
            fig = ancestor(chi,'figure');
        end
        if ~isempty(childType)
            type = get(chi,'Type');
            same = strcmp(type, childType);
            if include && ~same
                continue;
            end
            if ~include && same
                continue
            end
        end
        set(chi, {'ButtonDownFcn'},  uistate.ButtonDownFcns(i))
        set(chi, {'Interruptible'},  uistate.Interruptible(i))
        set(chi, {'BusyAction'},     uistate.BusyAction(i))
        if isfield(uistate,'docontext') && uistate.docontext
            % Do not set an invalid handle or a handle that belongs
            % to another figure. g239172
            if isempty(uistate.UIContextMenu{i}) || ...
               ( ishandle(uistate.UIContextMenu{i}) && ...
                 isequal(fig,ancestor(uistate.UIContextMenu{i},'figure')))
                    set(chi, {'UIContextMenu'}, uistate.UIContextMenu(i));
            end
        end
    end
end
