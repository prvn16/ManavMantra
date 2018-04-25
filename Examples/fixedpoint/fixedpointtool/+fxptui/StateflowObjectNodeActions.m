classdef StateflowObjectNodeActions < fxptui.AbstractSimulinkTreeNodeActions
% STATEFLOWOBJECTNODEACTIONS Manages actions for the stateflow objects in the FPT tree
    
% Copyright 2013-2015 The MathWorks, Inc.

    methods
        function this = StateflowObjectNodeActions(node)
            this@fxptui.AbstractSimulinkTreeNodeActions(node);
        end
        
        function invokeMethod(this, methodName)
            this.(methodName);
        end
    end
    
    methods(Access=protected)
        
        function action = getDefaultActions(this)
            action = this.getOpenAction;
        end
        
        function actions = getSupportedActions(this)
            [dto_actions, dto_applies_actions] = this.getDTOActions;
            mmo_actions = this.getMMOActions;
            actions = [mmo_actions dto_actions dto_applies_actions getSignalLoggingActions(this)];
        end
       
        function actions = getSignalLoggingActions(this)
            enable_cnt = 1;
            disable_cnt = 1;
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
        
        function [dto_actions, dto_applies_actions] = getDTOActions(this)
            dto_actions = this.getAction('DTO_DISABLE');
            dto_actions.disableAction;
            dto_applies_actions = [];
        end
        
        function actions = getMMOActions(this)
            actions = this.getAction('MMO_DISABLE');
            actions.disableAction;
        end
    end
end
