classdef MLWorkspaceBrowserManager < internal.matlab.variableeditor.MLManager
    % A class defining MATLAB Workspace Browser Manager
    % 

    % Copyright 2013-2014 The MathWorks, Inc.

    properties
        Workspace;
    end
    
    properties (SetObservable=false, SetAccess='immutable', GetAccess='public', Dependent=true, Hidden=false)
        WorkspaceKey;
    end
    
    methods
        function storedValue = get.WorkspaceKey(this)
            storedValue = this.getWorkspaceKey(this.Workspace);
        end
    end

    
    methods(Access='public')
        function this = MLWorkspaceBrowserManager(Workspace)
            this@internal.matlab.variableeditor.MLManager(false);
            this.Workspace = Workspace;
            this.initialize();
        end
    end
    
    methods(Access='protected')
        function initialize(this)
            % Create the DataModel, ViewModel, and Adapter specific to the
            % WorkspaceBrowser, and use this to create a single
            % WorkspaceDocument class
            DataModel = internal.matlab.workspace.MLWorkspaceDataModel(this.Workspace);
            ViewModel = internal.matlab.variableeditor.StructureViewModel(DataModel);
            Adapter = internal.matlab.workspace.MLWorkspaceAdapter(...
                DataModel.Name, DataModel.Workspace, DataModel, ViewModel);
            this.Documents = internal.matlab.workspace.MLWorkspaceDocument(this, Adapter, '');
        end
    end

end
