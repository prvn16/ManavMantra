classdef MLInspectorAdapter < internal.matlab.variableeditor.MLAdapter
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Adapter class for the inspector.  Stores the DataModel and ViewModel
    % for the Property Inspector.
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties (SetObservable = true, SetAccess = protected, ...
            Dependent = true)
        % DataModel Property
        DataModel;
    end
    
    methods
        function storedValue = get.DataModel(this)
            % Return the DataModel for scalar Workspaces.  Creates it the
            % first time if it hasn't been created yet.
            if isempty(this.DataModel_I)
                this.DataModel = ...
                    internal.matlab.inspector.MLInspectorDataModel(...
                    this.Name, this.Workspace);
            end
            storedValue = this.DataModel_I;
        end
        
        function set.DataModel(this, newValue)
            % Sets the DataModel for Workspaces.
            reallyDoCopy = ~isequal(this.DataModel_I, newValue);
            if reallyDoCopy
                this.DataModel_I = newValue;
            end
        end
    end
    
    % ViewModel
    properties (SetObservable = true, SetAccess = protected, ...
            Dependent = true)
        % ViewModel Property
        ViewModel;
    end
    
    methods
        function storedValue = get.ViewModel(this)
            % Return the ViewModel for scalar Workspaces.  Creates it the
            % first time if it hasn't been created yet.
            if isempty(this.ViewModel_I)
                this.ViewModel_I = ...
                    internal.matlab.inspector.InspectorViewModel(...
                    this.DataModel);
            end
            storedValue = this.ViewModel_I;
        end
        
        function set.ViewModel(this, newValue)
            % Sets the ViewModel for Workspaces
            reallyDoCopy = ~isequal(this.ViewModel_I, newValue);
            if reallyDoCopy
                this.ViewModel_I = newValue;
            end
        end
    end
    
    methods
        % Constructor - creates a new MLInspectorAdapter class
        function this = MLInspectorAdapter(name, workspace, DataModel, ...
                ViewModel)
            this.Name = name;
            this.Workspace = workspace;
            this.DataModel = DataModel;
            this.ViewModel = ViewModel;
        end
    end
end

