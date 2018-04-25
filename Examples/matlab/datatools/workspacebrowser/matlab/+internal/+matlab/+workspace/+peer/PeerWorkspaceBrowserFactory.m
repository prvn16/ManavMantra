classdef PeerWorkspaceBrowserFactory < handle
    % A class defining MATLAB PeerModel Workspace Browser Factory
    % 

    % Copyright 2013-2014 The MathWorks, Inc.

    % Property Definitions:

    properties (Constant)
        % PeerModelChannel
        PeerModelChannel = '/WorkspaceBrowserManager';

        % Force New Instance
        % Used to force creation of a new instance for testing purposes
        ForceNewInstance = 'force_new_instance';
    end

    properties (SetObservable=false, SetAccess='protected', GetAccess='public', Dependent=false, Hidden=false)
        PeerManager;
        Channel; 
    end
    
    % Peer Listener Properties
    properties (SetObservable=false, SetAccess='protected', GetAccess='public', Dependent=false, Hidden=false)
        PeerEventListener;
        PropertySetListener;
    end %properties
    
    % Constructor
    methods(Access='protected')
        function this = PeerWorkspaceBrowserFactory()
            this.Channel = internal.matlab.workspace.peer.PeerWorkspaceBrowserFactory.PeerModelChannel;
            Root = [internal.matlab.workspace.peer.PeerWorkspaceBrowserFactory.PeerModelChannel '_Root'];
            this.PeerManager = internal.matlab.variableeditor.peer.PeerManager(internal.matlab.workspace.peer.PeerWorkspaceBrowserFactory.PeerModelChannel, Root, true);

            % Add peer event listener
            this.PeerEventListener = ...
                event.listener(this.PeerManager.PeerModelServer.getRoot, ...
                'PeerEvent',@this.handlePeerEvent);
            this.PropertySetListener = event.listener(this.PeerManager.PeerModelServer.getRoot,'PropertySet',@this.handlePropertySet);

            this.PeerManager.setProperty('Initialized', true);

            % Send event for the factory ready
            internal.matlab.variableeditor.peer.PeerUtils.sendPeerEvent(this.PeerManager.getRoot(), 'FactoryInitialized');           
            
        end
        
    end
    
    % Public methods
    methods
        % Handles all peer events from the client
        function handlePeerEvent(this, ~, ed)
            if isfield(ed.EventData,'source') && strcmp('server',ed.EventData.source)
                return;
            end
            if isfield(ed.EventData,'type')
                try
                    switch ed.EventData.type
                        case 'CreateWorkspaceBrowser' % Fired to start a server peer manager
                            this.logDebug('PeerWorkspaceBrowserFactory','handlePeerEvent','CreateWorkspaceBrowser');
                            this.createWorkspaceBrowser(ed.EventData.workspace, ed.EventData.channel);
                        case 'DeleteWorkspaceBrowser' % Fired to start a server peer manager
                            this.logDebug('PeerWorkspaceBrowserFactory','handlePeerEvent','DeleteWorkspaceBrowser');
                            % Get the manager instance and delete it
                            if getWorkspaceBrowserInstances.isKey(ed.EventData.workspace)
                                manager = this.createWorkspaceBrowser(ed.EventData.workspace, ed.EventData.channel);
                                delete(manager);
                            end
                    end
                catch e
                    this.PeerManager.sendErrorMessage(e.message);
                end
            end
        end
        
        function status = handlePropertySet(this, ~, ed)
            % Handles properties being set.  ed is the Event Data, and it
            % is expected that ed.EventData.key contains the property which
            % is being set.  Returns a status: empty string for success,
            % an error message otherwise.
            status = '';
            
            if ~isa(ed.EventData.newValue, 'java.util.HashMap')
                return;
            end
            
            if ed.EventData.newValue.containsKey('Source') && strcmp('server',ed.EventData.newValue.get('Source'))
                return;
            end

        end
        
        function handlePropertyDeleted(this, ~, ~)
            this.PeerManager.sendErrorMessage(getString(message(...
                'MATLAB:codetools:variableeditor:NoPropertiesShouldBeRemoved')));
        end
        
        function logDebug(this, class, method, message, varargin)
            rootNode = this.PeerManager.getRoot();
            internal.matlab.variableeditor.peer.PeerUtils.logDebug(rootNode, class, method, message, varargin{:});
        end
    end
    
    % Public Static Methods
    methods(Static, Access='public')
        % getInstance
        function obj = getInstance(varargin)
            mlock; % Keep persistent variables until MATLAB exits
            persistent managerInstance;
            if isempty(managerInstance) || (nargin>0 && strcmpi(varargin{1},internal.matlab.workspace.peer.PeerManager.ForceNewInstance))
                managerInstance = internal.matlab.workspace.peer.PeerWorkspaceBrowserFactory();
            end
            obj = managerInstance;
        end
        
        function obj = getWorkspaceBrowserInstances(newWSBInstances)
            mlock; % Keep persistent variables until MATLAB exits
            persistent WSBInstances;
            
            % Factory Instance
            factoryInstance = internal.matlab.workspace.peer.PeerWorkspaceBrowserFactory.getInstance();

            if nargin > 0
                WSBInstances = newWSBInstances;
                factoryInstance.logDebug('PeerWorkspaceBrowserFactory','getWorkspaceBrowserInstances','set');
                keys = WSBInstances.keys();
                managerJSON = ['[' sprintf('"%s",',keys{:})];
                managerJSON(end) = ']';

                factoryInstance.PeerManager.setProperty('Managers', managerJSON);
            elseif isempty(WSBInstances)
                factoryInstance.logDebug('PeerWorkspaceBrowserFactory','getWorkspaceBrowserInstances','initial creation');
                WSBInstances = containers.Map();
            else
                factoryInstance.logDebug('PeerWorkspaceBrowserFactory','getWorkspaceBrowserInstances','get');
            end
            
            obj = WSBInstances;
        end

        function obj = createWorkspaceBrowser(Workspace, Channel)
            mlock; % Keep persistent variables until MATLAB exits
            persistent wsbCounter;
            persistent deleteListeners;
          
            if isempty(wsbCounter)
                wsbCounter = 0;
            end
            
            origWorkspaceEmpty = false;
            if nargin<1 || isempty(Workspace)
                origWorkspaceEmpty = true;
                Workspace = 'caller';
            end            

            if nargin<2 || isempty(Channel)
                wsbCounter = wsbCounter + 1;
                Channel = ['/WSB_' num2str(wsbCounter)];
            end

            factoryInstance = internal.matlab.workspace.peer.PeerWorkspaceBrowserFactory.getInstance();
            if ischar(Workspace)
                factoryInstance.logDebug('PeerWorkspaceBrowserFactory','createManager','','workspace',Workspace,'channel',Channel);
            else
                factoryInstance.logDebug('PeerWorkspaceBrowserFactory','createManager','','workspace','private','channel',Channel);
            end

            WSBInstances = internal.matlab.workspace.peer.PeerWorkspaceBrowserFactory.getWorkspaceBrowserInstances();
            if isempty(deleteListeners)
                deleteListeners = containers.Map();
            end

            if ~isKey(WSBInstances, Channel)
                % Check to see if the workspace is a standard workspace or we
                % need to attempt to evaluate that workspace
                if ischar(Workspace) && ~strcmpi('caller', Workspace) && ~strcmp('base', Workspace)
                    Workspace = eval(Workspace);
                end
                managerInstance = internal.matlab.workspace.peer.PeerWorkspaceBrowserManager(Workspace, Channel);
                WSBInstances(Channel) = managerInstance;
                 deleteListeners(Channel) = event.listener(managerInstance,...
                     'ObjectBeingDestroyed',localCreateObjectDestroyedCallbackWSB(Channel,WSBInstances));
                
                internal.matlab.workspace.peer.PeerWorkspaceBrowserFactory.getWorkspaceBrowserInstances(WSBInstances);
                
                % Make sure we add this manager to the Variable Editor
                % Factory
                veManagerInstances = internal.matlab.variableeditor.peer.PeerManagerFactory.getManagerInstances();
                if ~isKey(veManagerInstances, Channel)
                    veManagerInstances(Channel) = managerInstance;
                    deleteListeners([Channel '_VE']) = event.listener(managerInstance,...
                        'ObjectBeingDestroyed',...
                       localCreateObjectDestroyedCallbackVE(Channel,veManagerInstances));
                    internal.matlab.variableeditor.peer.PeerManagerFactory.getManagerInstances(veManagerInstances);
                end
            elseif ~origWorkspaceEmpty && ~isequal(WSBInstances(Channel).Workspace, Workspace) % Check to see if the user passed a new workspace
                % Check to see if the workspace is a standard workspace or we
                % need to attempt to evaluate that workspace
                evaluatedWorkspace = false;
                if ischar(Workspace) && ~strcmpi('caller', Workspace) && ~strcmp('base', Workspace)
                    evaluatedWorkspace = true;
                end
                
                if ~evaluatedWorkspace || (evaluatedWorkspace && ~strcmp(class(WSBInstances(Channel).Workspace), Workspace))
                   warning(message('MATLAB:workspace:PassedInWorkspaceDoesNotMatchExistingWorkspace'));
                end
            end
            
            % Return the new manager instances
            obj = WSBInstances(Channel);

            % Send event for the manager creation
            internal.matlab.variableeditor.peer.PeerUtils.sendPeerEvent(factoryInstance.PeerManager.getRoot(), 'WorkspaceBrowserCreated', 'Workspace', obj.WorkspaceKey, 'Channel', Channel);
        end
        
        function startup()
            % Makes sure the peer manager for the variable editor exists
            [~]=internal.matlab.workspace.peer.PeerWorkspaceBrowserFactory.getInstance();
        end
    end
    
    
end

function clb = localCreateObjectDestroyedCallbackWSB(Channel,WSBInstances)
clb =  @(~,~) (internal.matlab.workspace.peer.PeerWorkspaceBrowserFactory.getWorkspaceBrowserInstances(WSBInstances.remove(Channel)));
end

function clb = localCreateObjectDestroyedCallbackVE(Channel,veManagerInstances)
clb =  @(~,~) (internal.matlab.variableeditor.peer.PeerManagerFactory.getManagerInstances(veManagerInstances.remove(Channel)));
end


