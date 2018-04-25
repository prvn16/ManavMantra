classdef ModelReferenceNodeActions < fxptui.AbstractSimulinkTreeNodeActions
% MODELREFERNCENODEACTIONS Class that defines the actions available on the model reference nodes in FPT
    
% Copyright 2013-2015 The MathWorks, Inc.
    
    methods
        function this = ModelReferenceNodeActions(node)
            this@fxptui.AbstractSimulinkTreeNodeActions(node);
        end
        
        function invokeMethod(this, methodName, varargin)
            this.(methodName)(varargin{:});
        end
    end
    
    methods(Access=protected)
        function action = getDefaultActions(this)
            action = this.getOpenAction;
        end
        
        function actions = getSupportedActions(this)
            hilite_action = this.getAction('HILITE_SYSTEM');
            unhilite_action = this.getAction('HILITE_CLEAR');
            [dto_actions, dto_applies_actions] = this.getDTOActions;
            mmo_actions = this.getMMOActions;
            
            hiliteRelatedActions = [hilite_action unhilite_action];
            mmoDtoActions = [mmo_actions dto_actions dto_applies_actions ];
                   
            actions = [hiliteRelatedActions mmoDtoActions getSignalLoggingActions(this)];
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
                % ignore error. Don't provide action for this. Not
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
                % ignore error. Don't provide action for this. Not
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
        
        function changeDTO(this, paramValue)
            sysObj = this.TreeNode.getDAObject;
            subModel = sysObj.ModelName;
            subModelObj = get_param(subModel,'Object');
            subModelObj.DataTypeOverride = paramValue;
            % force a property change on the model reference block to
            % update its label
            this.TreeNode.firePropertyChanged;

        end
        
        function changeDTOAppliesTo(this, paramValue)
            sysObj = this.TreeNode.getDAObject;
            subModel = sysObj.ModelName;
            subModelObj = get_param(subModel,'Object'); 
            subModelObj.DataTypeOverrideAppliesTo =  paramValue;
        end
        
        function changeMMO(this, paramValue)
            sysObj = this.TreeNode.getDAObject;
            subModel = sysObj.ModelName;
            subModelObj = get_param(subModel,'Object');
            subModelObj.MinMaxOverflowLogging = paramValue;
            % force a property change on the model reference block to
            % update its label
            this.TreeNode.firePropertyChanged;

        end
    end
end
