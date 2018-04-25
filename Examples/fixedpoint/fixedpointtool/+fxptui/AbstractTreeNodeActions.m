classdef AbstractTreeNodeActions < handle
% ABSTRACTTREENODEACTIONS Abstract class to define the actions available on tree nodes in FPT
    
% Copyright 2013-2015 The MathWorks, Inc.
    
    properties(GetAccess = protected, SetAccess = private)
        Actions
        TreeNode
    end
    
    methods
        function this = AbstractTreeNodeActions(node)
            this.TreeNode = node;
        end
        
        function actions = getActions(this)
            actions = this.createActions; 
        end
        
        function delete(this)
            deleteActions(this);
            this.Actions = [];
        end
        
        function invokeMethod(this, methodName)
            this.(methodName);
        end
    end
    
    methods (Abstract, Access = protected)
        actions = getSupportedActions(this);
        actions = getSignalLoggingActions(this);
        setSUD(this);        
    end
    
    methods(Access=private)
        function actions = createActions(this)
            defaultActions = this.getDefaultActions;
            childActions = this.getSupportedActions;
            actions = [defaultActions childActions];
            this.Actions = actions;
        end
        
        function deleteActions(this)
            for i = 1:length(this.Actions)
                delete(this.Actions(i));
            end
        end
    end
    
    methods(Access=protected)
        
        function opensystem(this)
            % Open the system in the native editor
           this.TreeNode.getUniqueIdentifier.openInEditor; 
        end
        
        function action = getOpenAction(~)
            action = fxptds.Action('',...
                fxptui.message('actionOPENSYSTEM'), 'FPT_simulink_opensys',...
                'fxptui.AbstractTreeNodeActions.selectAndInvoke(''opensystem'')');
        end
        
        function actions = getDefaultActions(this)
        % Define default actions here for the tree nodes
    
           openAction = this.getOpenAction;
           sudAction = fxptds.Action('', ...
               fxptui.message('labelSUDContextMenu'), ...
               'FPT_sud_tree',...
               'fxptui.AbstractTreeNodeActions.selectAndInvoke(''setSUD'')');
            actions = [sudAction openAction];
        end
        
    end
    
    methods (Static)
        function selectAndInvoke(methodName, varargin)
            me = fxptui.getexplorer; 
            if isempty(me); return; end
            selection = me.getSelectedTreeNode;
            selection.getActionHandler.invokeMethod(methodName, varargin{:});
        end
    end
end
