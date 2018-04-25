classdef MATLABFunctionNodeActions < fxptui.AbstractSimulinkTreeNodeActions
    % MATLABFUNCTIONNODEACTIONS Supported actions for the MATLAB function
    % node in FPT tree
    
    % Copyright 2014-2015 The MathWorks, Inc.
    
    methods
        function this = MATLABFunctionNodeActions(node)
            this@fxptui.AbstractSimulinkTreeNodeActions(node);
        end
        
        function invokeMethod(this, methodName)
            this.(methodName);
        end
    end
    
    methods(Access=protected)
        function actions = getSupportedActions(this)
            [dto_actions, dto_applies_actions] = this.getDTOActions;
            mmo_actions = this.getMMOActions;
            codeViewActions = this.getCodeViewActions();
            actions = [codeViewActions mmo_actions dto_actions dto_applies_actions this.getSignalLoggingActions];
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
        function actions = getSignalLoggingActions(~)
            % Signal logging not supported.
            actions = [];
        end
        
    end
end
