classdef PeerWorkspaceBrowserManager < internal.matlab.workspace.MLWorkspaceBrowserManager & internal.matlab.variableeditor.peer.PeerManager
    % A class defining MATLAB PeerModel Workspace Broswer
    % 

    % Copyright 2013-2014 The MathWorks, Inc.

    % Property Definitions:

    % Constructor
    methods(Access='public')
        function this = PeerWorkspaceBrowserManager(Workspace, Channel)
            this@internal.matlab.variableeditor.peer.PeerManager(Channel, '/WorkspaceBrowser_Root', false);
            this@internal.matlab.workspace.MLWorkspaceBrowserManager(Workspace);
            this.Workspace = Workspace;
        end
    end
    
    methods(Access='protected')
        function initialize(this)
            % The workspace could be a key so fetch the actual workspace
            % object
            this.Workspace = this.getWorkspace(this.Workspace);

            DataModel = internal.matlab.workspace.MLWorkspaceDataModel(this.Workspace);
            ViewModel = internal.matlab.variableeditor.StructureViewModel(DataModel);
            Adapter = internal.matlab.workspace.peer.PeerWorkspaceAdapter(...
                DataModel.Name, DataModel.Workspace, DataModel, ViewModel);
            this.Documents = internal.matlab.workspace.peer.PeerWorkspaceDocument(...
                this.getRoot(), this, Adapter, '');
            this.FocusedDocument = this.Documents(1);
            DataModel.Data = struct();

            % Get the mapped workspace key
            workspaceKey = this.WorkspaceKey;

            % Do initial population for the workspace
            % If we don't have a Workspace-Like Object or the base
            % workspace we need to call an asynchronous upate using a
            % WebWorker
            if ischar(this.Workspace) && isequal(this.Workspace, 'base')
                openCmd = ['internal.matlab.workspace.peer.PeerWorkspaceBrowserFactory.createWorkspaceBrowser(''' ...
                    workspaceKey ''',''' this.Channel ''').Documents.DataModel.workspaceUpdated;'];
                com.mathworks.datatools.variableeditor.web.WebWorker.executeCommand(openCmd);
            else
                DataModel.workspaceUpdated();
            end
        end
    end

    % Public Methods
    methods(Access='public')
        function closevar(~, ~, ~)
            % Nothing to do here
        end
        
        function reinitialize(this)
            % Deletes the current Workspace Document in order to force a
            % refresh of the Workspace Peer Stack
            delete(this.Documents);
            this.initialize();
        end
    end
end
