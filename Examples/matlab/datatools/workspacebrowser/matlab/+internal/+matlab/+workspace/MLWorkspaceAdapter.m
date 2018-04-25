classdef MLWorkspaceAdapter < internal.matlab.variableeditor.MLAdapter
    %MLWorkspaceAdapter
    %   MATLAB Workspace Variable Editor Mixin

    % Copyright 2013 The MathWorks, Inc.

    % DataModel
    properties (SetObservable=true, SetAccess='protected', GetAccess='public', Dependent=true, Hidden=false)
        % DataModel Property
        DataModel;
    end
    
    methods
        function storedValue = get.DataModel(this)
            % Return the DataModel for scalar Workspaces.  Creates it the
            % first time if it hasn't been created yet.
            if isempty(this.DataModel_I)
                this.DataModel = internal.matlab.workspace.MLWorkspaceDataModel(...
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
    properties (SetObservable=true, SetAccess='protected', GetAccess='public', Dependent=true, Hidden=false)
        % ViewModel Property
        ViewModel;
    end
    
    methods
        function storedValue = get.ViewModel(this)
            % Return the ViewModel for scalar Workspaces.  Creates it the
            % first time if it hasn't been created yet.
            if isempty(this.ViewModel_I)
                this.ViewModel_I = internal.matlab.variableeditor.StructureViewModel(...
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

    % Constructor
    methods
        function this = MLWorkspaceAdapter(name, workspace, DataModel, ViewModel)
            this.Name = name;
            this.Workspace = workspace;
            this.DataModel = DataModel;
            this.ViewModel = ViewModel;
        end
    end
end

