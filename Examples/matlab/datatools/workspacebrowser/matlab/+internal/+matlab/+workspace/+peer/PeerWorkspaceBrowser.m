classdef PeerWorkspaceBrowser < internal.matlab.workspace.MLWorkspaceBrowser
    % A class defining MATLAB PeerModel Workspace Broswer
    % 

    % Copyright 2013-2017 The MathWorks, Inc.

    % Property Definitions:

    properties (Constant)
        % PeerModelChannel
        PeerModelChannel = '/WorkspaceBrowser';
        ActionManagerNamespace = '/WSBActionManager';
        startPath = 'internal.matlab.workspace.actions'; 
        ContextMenuManagerNamespace = '/WSBContextMenuManager';
        % This file contains the WorkspaceBrowser actions. If it doesn't exist, this condition is handled and no actions are created
        WSBContextMenuActionsFile = fullfile(matlabroot,'toolbox','matlab','datatools','workspacebrowser','matlab','+internal','+matlab',...
                                            '+workspace','+ActionMapping','WSBActionGroupings.xml');
    end
    
    properties (SetAccess = 'protected')
        WSBActionManager;
        ContextMenuManager;
    end
    
    % Constructor
    methods(Access='protected')
        function this = PeerWorkspaceBrowser()
            mlock; % Keep persistent variables until MATLAB exits
            this@internal.matlab.workspace.MLWorkspaceBrowser();
            this.initialize();
            this.initWSBActions();
            this.initWSBContextMenu();            
        end
        
        % Starts up the Workspacebrowser's ActionDataService using
        % ActionManager that instantiates all the Actions. Every
        % workspacebrowser Action inherits from the 'VEAction' class.
        function initWSBActions(this)
            actionNamespace = internal.matlab.workspace.peer.PeerWorkspaceBrowser.ActionManagerNamespace;            
            pathToScan = internal.matlab.workspace.peer.PeerWorkspaceBrowser.startPath;
            this.WSBActionManager = this.Manager.initActions(actionNamespace, pathToScan);            
        end 

        % Starts up the Workspacebrowser's ContextMenuManager Service by passing in 
        % Workspacebrowser's ContextNamespace, ActionNamespace, queryString
        % used as a selector on client side and path of the XML file containing the Contextmenu options.
        function initWSBContextMenu(this)
            actionNamespace = internal.matlab.workspace.peer.PeerWorkspaceBrowser.ActionManagerNamespace;
            contextNamespace = internal.matlab.workspace.peer.PeerWorkspaceBrowser.ContextMenuManagerNamespace;
            % For now, the contextmenus are only for the dataScrollerNode
            % and not for the entire PeerDocument.             
            queryString = ['[data-ManagerChannel=''' this.Manager.Channel '''] .dataScrollerNode'];
            pathToXMLFile = internal.matlab.workspace.peer.PeerWorkspaceBrowser.WSBContextMenuActionsFile;
            this.ContextMenuManager = this.Manager.initContextMenu(actionNamespace, queryString, pathToXMLFile, contextNamespace);           
        end        
    end
    
    methods(Access='protected')
        function initialize(this)
            this.Manager = internal.matlab.workspace.peer.PeerWorkspaceBrowserFactory.createWorkspaceBrowser('caller', internal.matlab.workspace.peer.PeerWorkspaceBrowser.PeerModelChannel);
            % Force an initial update from the base workspace g1044049
            this.Manager.Documents(1).DataModel.Workspace = 'base';
            this.Manager.Documents(1).DataModel.workspaceUpdated();
            this.Manager.Documents(1).DataModel.Workspace = 'caller';
        end
    end

    % Public Static Methods
    methods(Static, Access='public')
        % getInstance
        function obj = getInstance()
            mlock; % Keep persistent variables until MATLAB exits

            % Gets the persistent instance of the workspace browser
            persistent managerInstance;
            if isempty(managerInstance)
                managerInstance = internal.matlab.workspace.peer.PeerWorkspaceBrowser();
            end
            obj = managerInstance;
        end
        
        function startup()
            % Makes sure the peer manager for the workspace browser exists
            [~]=internal.matlab.workspace.peer.PeerWorkspaceBrowser.getInstance();

            % Make sure the peer manager for the variable editor exists
            internal.matlab.variableeditor.peer.PeerVariableEditor.startup();
        end
    end
    
    % Public Methods
    methods(Access='public')
        function reinitialize(this)
            % Deletes the current Workspace Document in order to force a
            % refresh of the Workspace Peer Stack
            this.Manager.reinitialize();
            this.initialize();
        end
    end
end
