function cm = getContextMenu(this, ~)

% Copyright 2013-2015 The MathWorks, Inc.

% GETCONTEXTMENU Returns the context menu for the node
cm = [];

actionHandler = this.getActionHandler;
try
    supported_actions = actionHandler.getActions;
    me = fxptui.getexplorer;
    if isempty(me)      
        return; 
    end
    am = DAStudio.ActionManager;
    cm = am.createPopupMenu(me);
    first_enable_item = 1;
    first_disable_item = 1;
    first_dto_item = 1;
    first_dto_applies_item = 1;
    first_mmo_item = 1;
    for i = 1:length(supported_actions)
        switch supported_actions(i).MenuGroup
            case fxptui.message('menuEnableLogging')
                if isequal(first_enable_item,1);
                    cm.addSeparator;
                    sm = am.createPopupMenu(me);
                    first_enable_item = 0;
                    cm.addSubMenu(sm, supported_actions(i).MenuGroup)
                end
                action = me.getaction(supported_actions(i).UniqueTag);
                if isempty(action)
                    action = me.createAction(supported_actions(i));
                end
                action.enabled = 'on';
                sm.addMenuItem(action);
            case fxptui.message('menuDisableLogging')
                 if isequal(first_disable_item,1);
                    cm.addSeparator;
                    dm = am.createPopupMenu(me);
                    first_disable_item = 0;
                    cm.addSubMenu(dm, supported_actions(i).MenuGroup)
                end
                action = me.getaction(supported_actions(i).UniqueTag);
                if isempty(action)
                    action = me.createAction(supported_actions(i));
                end
                action.enabled = 'on';
                dm.addMenuItem(action);
                
            case fxptui.message('labelLoggingMode')
                if isequal(first_mmo_item,1);
                    cm.addSeparator;
                    sm = am.createPopupMenu(me);
                    first_mmo_item = 0;
                    cm.addSubMenu(sm, supported_actions(i).MenuGroup)
                    cm.addSeparator;
                end
                action = me.getaction(supported_actions(i).UniqueTag);
                if isempty(action)
                    action = me.createAction(supported_actions(i));
                end
                action.enabled = 'on';
                if ~supported_actions(i).Enabled
                    action.enabled = 'off';
                end
                sm.addMenuItem(action);
                
            case fxptui.message('labelDataTypeOverride')
                if isequal(first_dto_item,1);
                    cm.addSeparator;
                    sm = am.createPopupMenu(me);
                    first_dto_item = 0;
                    cm.addSubMenu(sm, supported_actions(i).MenuGroup)
                end
                action = me.getaction(supported_actions(i).UniqueTag);
                if isempty(action)
                    action = me.createAction(supported_actions(i));
                end
                action.enabled = 'on';
                if ~supported_actions(i).Enabled
                    action.enabled = 'off';
                end
                sm.addMenuItem(action);
            case fxptui.message('labelDataTypeOverrideAppliesTo')
                if isequal(first_dto_applies_item,1);
                    %cm.addSeparator;
                    sm = am.createPopupMenu(me);
                    first_dto_applies_item = 0;
                    cm.addSubMenu(sm, supported_actions(i).MenuGroup)
                end
                action = me.getaction(supported_actions(i).UniqueTag);
                if isempty(action)
                    action = me.createAction(supported_actions(i));
                end
                action.enabled = 'on';
                sm.addMenuItem(action);
            otherwise
                action = me.getaction(supported_actions(i).UniqueTag);
                if isempty(action)
                    action = me.createAction(supported_actions(i));
                end
                action.enabled = 'on';
                cm.addMenuItem(action);
        end
    end
catch
    % Ignore any errors here. Throwing the error to the caller can cause a
    % MATLAB crash on the GUI thread.    
end
end
