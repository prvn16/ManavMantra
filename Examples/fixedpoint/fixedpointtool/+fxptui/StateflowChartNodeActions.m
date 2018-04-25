classdef StateflowChartNodeActions < fxptui.AbstractSimulinkTreeNodeActions
% STATEFLOWCHARTNODEACTIONS defines the actions on a stateflow chart node in FPT
    
% Copyright 2013-2015 The MathWorks, Inc.
    
    methods
        function this = StateflowChartNodeActions(node)
            this@fxptui.AbstractSimulinkTreeNodeActions(node);
        end
        
        function invokeMethod(this, methodName, varargin)
            this.(methodName)(varargin{:});
        end
    end
    
    methods(Access=protected)
        function actions = getSupportedActions(this)
            hilite_action = this.getAction('HILITE_SYSTEM');
            unhilite_action = this.getAction('HILITE_CLEAR');
            codeViewActions = this.getCodeViewActions();
            
            [dto_actions, dto_applies_actions] = this.getDTOActions;
            mmo_actions = this.getMMOActions;
            hiliteRelateActions = [hilite_action  unhilite_action];
            mmoDtoActions = [mmo_actions dto_actions dto_applies_actions];
            
            actions = [codeViewActions hiliteRelateActions mmoDtoActions getSignalLoggingActions(this)];
        end
        
        function actions = getSignalLoggingActions(this)
            enable_cnt = 1;
            disable_cnt = 1;
            try
                if this.TreeNode.isOutportEnabled
                    action = this.getAction('LOG_OUTPORT_SYS');
                    if ~isempty(action)
                        enable_actions(enable_cnt) = action;
                        enable_cnt = enable_cnt + 1;
                    end
                    
                    action = this.getAction('LOG_NO_OUTPORT_SYS');
                    if ~isempty(action)
                        disable_actions(disable_cnt) = action;
                        disable_cnt = disable_cnt + 1;
                    end
                end
            catch
                % Ignore error. Don't provide action for this. Not
                % protecting this code can lead to crashes on the UI thread
                % later on.
            end
            try
                if this.TreeNode.hasLoggableSignals
                    action = this.getAction('LOG_ALL_SYS');
                    if ~isempty(action)
                        enable_actions(enable_cnt) = action;
                        enable_cnt = enable_cnt + 1;
                    end
                    
                    action = this.getAction('LOG_NONE_SYS');
                    if ~isempty(action)
                        disable_actions(disable_cnt) = action;
                        disable_cnt = disable_cnt + 1;
                    end
                end
            catch
                % Ignore error. Don't provide action for this. Not
                % protecting this code can lead to crashes on the UI thread
                % later on.
            end
            try
                if this.TreeNode.hasSubsystemInHierarchy
                    action = this.getAction('LOG_ALL');
                    if ~isempty(action)
                        enable_actions(enable_cnt) = action;
                        enable_cnt = enable_cnt + 1;
                    end
                    action = this.getAction('LOG_NAMED');
                    if ~isempty(action)
                        enable_actions(enable_cnt) = action;
                        enable_cnt = enable_cnt + 1;
                    end
                    action = this.getAction('LOG_UNNAMED');
                    if ~isempty(action)
                        enable_actions(enable_cnt) = action;
                        enable_cnt = enable_cnt + 1;
                    end
                    
                    action = this.getAction('LOG_NONE');
                    if ~isempty(action)
                        disable_actions(disable_cnt) = action;
                        disable_cnt = disable_cnt + 1;
                    end
                    
                    action = this.getAction('LOG_NO_NAMED');
                    if ~isempty(action)
                        disable_actions(disable_cnt) = action;
                        disable_cnt = disable_cnt + 1;
                    end
                    
                    action = this.getAction('LOG_NO_UNNAMED');
                    if ~isempty(action)
                        disable_actions(disable_cnt) = action;
                        disable_cnt = disable_cnt + 1;
                    end
                end
            catch 
                % Ignore error. Don't provide action for this. Not
                % protecting this code can lead to crashes on the UI thread
                % later on.
            end
            actions = [];
            if enable_cnt > 1
                actions = enable_actions;
            end
            if disable_cnt > 1
                actions = [actions disable_actions];
            end
        end
    end
end
