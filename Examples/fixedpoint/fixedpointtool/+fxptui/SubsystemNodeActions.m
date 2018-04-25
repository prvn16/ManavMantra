classdef SubsystemNodeActions < fxptui.AbstractSimulinkTreeNodeActions
% SUBSYSTEMNODEACTIONS Class that defines the actions available on the subsystem nodes in FPT
    
% Copyright 2013-2015 The MathWorks, Inc.
    
    methods
        function this = SubsystemNodeActions(node)
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
            mmo_actions = this.getMMOActions;
                [dto_actions, dto_applies_actions] = this.getDTOActions;   
            codeViewActions = this.getCodeViewActions();
            
            actions = [codeViewActions hilite_action  unhilite_action ...
                mmo_actions dto_actions dto_applies_actions];
   
            if ~this.TreeNode.isParentLinked
                actions = [actions getSignalLoggingActions(this)];
            end
        end
        
                       
        function actions = getSignalLoggingActions(this)
            enable_cnt = 1;
            disable_cnt = 1;
            if this.TreeNode.isLinked
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
                else
                    enable_actions = [];
                    disable_actions = [];
                end
            else
                if this.TreeNode.isOutportEnabled
                    action = this.getAction('LOG_OUTPORT_SYS');
                    if ~isempty(action)
                        enable_actions(enable_cnt) = action;
                        enable_cnt = enable_cnt + 1;
                    end
                end
                action = this.getAction('LOG_ALL_SYS');
                if ~isempty(action)
                    enable_actions(enable_cnt) = action;
                    enable_cnt = enable_cnt + 1;
                end
                action = this.getAction('LOG_NAMED_SYS');
                if ~isempty(action)
                    enable_actions(enable_cnt) = action;
                    enable_cnt = enable_cnt + 1;
                end
                action = this.getAction('LOG_UNNAMED_SYS');
                if ~isempty(action)
                    enable_actions(enable_cnt) = action;
                    enable_cnt = enable_cnt + 1;
                end
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
                
                if this.TreeNode.isOutportEnabled
                    action = this.getAction('LOG_NO_OUTPORT_SYS');
                    if ~isempty(action)
                        disable_actions(disable_cnt) = action;
                        disable_cnt = disable_cnt + 1;
                    end
                end
                action = this.getAction('LOG_NONE_SYS');
                if ~isempty(action)
                    disable_actions(disable_cnt) = action;
                    disable_cnt = disable_cnt + 1;
                end
                
                action = this.getAction('LOG_NO_NAMED_SYS');
                if ~isempty(action)
                    disable_actions(disable_cnt) = action;
                    disable_cnt = disable_cnt + 1;
                end
                
                action = this.getAction('LOG_NO_UNNAMED_SYS');
                if ~isempty(action)
                    disable_actions(disable_cnt) = action;
                    disable_cnt = disable_cnt + 1;
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
                    disable_actions(end+1) = action;
                end
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
