classdef TreeNodeAdapter < appdesigner.internal.componentadapterapi.VisualComponentAdapter
    % Adapter for a TreeNode component
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess=protected, GetAccess=public)
        % an array of properties, where the order in the array determines
        % the order the properties must be set for Code Generation and when
        % instantiating the MCOS component at design time.
        OrderSpecificProperties = {};
        
        % the "Value" property of the component
        ValueProperty = 'Text';
    end

    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = TreeNodeAdapter(varargin)
            obj@appdesigner.internal.componentadapterapi.VisualComponentAdapter(varargin{:});
        end
        
        function defaultValues = getComponentRunTimeDefaults(obj)
            % override the base version because this
            % component cannot be parented to uifigure to get runtime
            % defaults
            component = feval(obj.getComponentType());
            defaultValues = get(component);
            delete(component);
        end
        
    end
    
    methods(Access = protected)
        function parent = createDesignTimeParentComponent(obj)
            % Needs to be parented to Tree, and then Tree to
            % be under parent accordingly so all the default values are
            % initialized correctly            
            
            % Create UIFigure as a parent to ButtonGroup
            uiFigure = createDesignTimeParentComponent@...
                appdesigner.internal.componentadapterapi.VisualComponentAdapter(obj);
            
            % Create ButtonGroup as a parent for RadioButton
            treeAdapter = appdesigner.internal.componentadapter.uicomponents.adapter.TreeAdapter();
            parent = treeAdapter.createDesignTimeComponent(uiFigure);
        end
        
        function defaultValues = customizeComponentDesignTimeDefaults(obj, defaultValues)
            % The run-time component generates unique string value per
            % TreeNode using a UUID utility, on the server. For example:           
            % "24bc7d66-bcda-405f-a82b-887f66e7aa0a"
            % Saving this as a default will be misleading.
            %
            % But it needs to be generated in App Designer too, just that
            % it will be client-side
            %
            % So, keep this property to help integrators reason on it,
            % but set it to be empty, Its set to a cellstr which causes
            % it to be converted to a JS 1-element array which is its expected
            % type on the client
            defaultValues.NodeId = cellstr("");
        end
    end
    
    % ---------------------------------------------------------------------
    % Basic Registration Methods
    % ---------------------------------------------------------------------
    methods(Static)
        function className = getComponentType()
            className = 'matlab.ui.container.TreeNode';
        end
        
        function adapter = getJavaScriptAdapter()
            adapter = 'uicomponents_appdesigner_plugin/model/TreeNodeModel';
        end
    end
    
    % ---------------------------------------------------------------------
    % Code Gen Methods
    % ---------------------------------------------------------------------
    methods(Static)
        
        function codeSnippet = getCodeGenCreation(componentHandle, codeName, parentName)
            codeSnippet = sprintf('uitreenode(%s)', parentName);
        end
    end
    
end
