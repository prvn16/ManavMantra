classdef ModelNodeActions < fxptui.AbstractSimulinkTreeNodeActions
% MODELNODEACTIONS Class that defines the actions available on the model nodes in FPT
    
% Copyright 2013-2015 The MathWorks, Inc.
    
    methods
        function this = ModelNodeActions(node)
            this@fxptui.AbstractSimulinkTreeNodeActions(node);
        end
        
        function invokeMethod(this, methodName, varargin)
            this.(methodName)(varargin{:});
        end
    end
    
    methods(Access=protected)
        function actions = getSupportedActions(this)
            [dto_actions, dto_applies_actions] = this.getDTOActions;
            mmo_actions = this.getMMOActions;
            codeViewActions = this.getCodeViewActions();
            actions = [codeViewActions mmo_actions dto_actions dto_applies_actions getSignalLoggingActions(this)];
        end
        
        function actions = getSignalLoggingActions(this)
            enable_cnt = 1;
            disable_cnt = 1;
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
                disable_actions(disable_cnt) = action;
                disable_cnt = disable_cnt + 1;
            end
            actions = [];
            if enable_cnt > 1
                actions = enable_actions;
            end
            if disable_cnt > 1
                actions = [actions disable_actions];
            end
            %%
            % 
            % # ITEM1
            % # ITEM2
            % 
        end
    end    
end
