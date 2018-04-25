classdef PeerVariableEditor < handle
    % A class defining MATLAB Peer Variable Editor
    % 

    % Copyright 2013-2017 The MathWorks, Inc.

    % Property Definitions:

    properties(Constant)
        PeerModelChannel = '/VariableEditor';
        ActionManagerNamespace = '/VEActionManager';
        startPath = 'internal.matlab.variableeditor.Actions'; 
        ContextMenuManagerNamespace = '/VEContextMenuManager';
        % This file contains the Variable Editor actions. If it doesn't exist, this condition is handled and no actions are created
        VEContextMenuActionsFile = fullfile(matlabroot,'toolbox','matlab','datatools','variableeditor','matlab','+internal','+matlab',...
                                            '+variableeditor','+ActionMapping','VEActionGroupings.xml');        
    end
    
    properties (SetAccess = 'protected')
        VEActionManager;
        CodePublishingEnabledListener = [];
        ContextMenuManager;
    end

    properties (SetObservable=false, SetAccess='protected', GetAccess='protected', Dependent=false, Hidden=false)
        PeerManager_I;
    end
    
    properties (SetObservable=false, SetAccess='protected', GetAccess='public', Dependent=true, Hidden=false)
        PeerManager;
    end
    
    methods
        function storedValue = get.PeerManager(this)
            if isempty(this.PeerManager_I) || ~isvalid(this.PeerManager_I)
                this.PeerManager_I = internal.matlab.variableeditor.peer.PeerManagerFactory.getInstance.createInstance(internal.matlab.variableeditor.peer.PeerVariableEditor.PeerModelChannel, false);
            end
            storedValue = this.PeerManager_I;
        end
        
        function set.PeerManager(this, newValue)
            reallyDoCopy = ~isequal(this.PeerManager_I, newValue);
            if reallyDoCopy
                this.PeerManager_I = newValue;
            end
        end
    end
    
    properties (SetObservable=false, GetAccess='public', Dependent=true, Hidden=false)
        Documents;
    end
    methods
        function storedValue = get.Documents(this)
            storedValue = this.PeerManager.Documents;
        end
    end
    
    methods(Access='protected')
        % Constructor
        function this = PeerVariableEditor()
			this.PeerManager_I = internal.matlab.variableeditor.peer.PeerManagerFactory.getInstance.createInstance(internal.matlab.variableeditor.peer.PeerVariableEditor.PeerModelChannel, false);
            this.initVEActions();  
            this.initCodePublishing();
            this.initVEContextMenu();            
        end
        
        % Sets up code publishing by enabling
        function initCodePublishing(this)
            if isempty(this.CodePublishingEnabledListener)
                s = settings;
                this.CodePublishingEnabledListener = addlistener(...
                    s.matlab.desktop.arrayeditor, ...
                    'VECmdLineCodeGenEnabled', 'PostSet', ...
                    @this.handleCmdLineCodeGenEnabled);
                
                enabled = s.matlab.desktop.arrayeditor.VECmdLineCodeGenEnabled.ActiveValue;
                this.PeerManager_I.setProperty('VECmdLineCodeGenEnabled', enabled);
            end
        end

        function handleCmdLineCodeGenEnabled(this, ~, ed)
            enabled = ed.AffectedObject.VECmdLineCodeGenEnabled.ActiveValue;
            this.PeerManager_I.setProperty('VECmdLineCodeGenEnabled', enabled);
        end

        % Starts up the Variable Editor's ActionDataService using
        % ActionManager that instantiates all the VEActions.
        function initVEActions(this)
            actionNamespace = internal.matlab.variableeditor.peer.PeerVariableEditor.ActionManagerNamespace;            
            pathToScan = internal.matlab.variableeditor.peer.PeerVariableEditor.startPath;
            this.VEActionManager = this.PeerManager_I.initActions(actionNamespace, pathToScan);   
        end   

        % Starts up the VariableEditor's ContextMenuManager Service by passing in 
        % Variable Editor's ContextNamespace, ActionNamespace, queryString
        % used as a selector on client side and path of the XML file containing the Contextmenu options.
        function initVEContextMenu(this)
            actionNamespace = internal.matlab.variableeditor.peer.PeerVariableEditor.ActionManagerNamespace;
            contextNamespace = internal.matlab.variableeditor.peer.PeerVariableEditor.ContextMenuManagerNamespace;
            queryString = ['[data-ManagerChannel=''' this.PeerManager_I.Channel ''']'];
            pathToXMLFile = internal.matlab.variableeditor.peer.PeerVariableEditor.VEContextMenuActionsFile;
            this.ContextMenuManager = this.PeerManager_I.initContextMenu(actionNamespace, queryString, pathToXMLFile, contextNamespace);           
        end        
    end
    
    % Public Static Methods
    methods(Static, Access='public')
        % getInstance
        function obj = getInstance(varargin)
            mlock; % Keep persistent variables until MATLAB exits
            persistent managerInstance;
            if isempty(managerInstance) || (nargin>0 && strcmpi(varargin{1},internal.matlab.variableeditor.peer.PeerManager.ForceNewInstance))
                managerInstance = internal.matlab.variableeditor.peer.PeerVariableEditor();
            end
            obj = managerInstance;
        end
        
        function startup()
            % Makes sure the peer manager for the variable editor exists
            [~] = internal.matlab.variableeditor.peer.PeerVariableEditor.getInstance;
        end
        
        % Passthrough convinience methods
        function varDocument = openvar(name, workspace, data, userContext)
            if nargin < 2 || isempty(workspace)
                workspace = 'caller';
            end

            % NullValueObject - signals that we have to ask MATLAB for the
            % data
            if nargin<=2 || isa(data,'internal.matlab.variableeditor.NullValueObject')
                try
                    data = evalin(workspace, name);
                catch
                    data = internal.matlab.variableeditor.NullValueObject(name);
                end
            end

            if nargin<=3 || isempty(userContext)
                userContext = '';
            end

            varDocument = internal.matlab.variableeditor.peer.PeerVariableEditor.getInstance.PeerManager.openvar(name, workspace, data, userContext);
        end
        
        function closevar(name, workspace)
            if nargin < 2 || isempty(workspace)
                workspace = 'caller';
            end
            internal.matlab.variableeditor.peer.PeerVariableEditor.getInstance.PeerManager.closevar(name, workspace);
        end
        
        function closeAllVariables()
            internal.matlab.variableeditor.peer.PeerVariableEditor.getInstance.PeerManager.closeAllVariables();
        end

        function hasDoc = containsDocument(doc)
            hasDoc = internal.matlab.variableeditor.peer.PeerVariableEditor.getInstance.PeerManager.containsDocument(doc);
        end

        function index = documentIndex(name, workspace)
            if nargin < 2 || isempty(workspace)
                workspace = 'caller';
            end
            index = internal.matlab.variableeditor.peer.PeerVariableEditor.getInstance.PeerManager.documentIndex(name, workspace);
        end

        function index = docIdIndex(docID)
            index = internal.matlab.variableeditor.peer.PeerVariableEditor.getInstance.PeerManager.docIdIndex(docID);
        end
    end
end
