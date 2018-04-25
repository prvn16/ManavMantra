classdef PeerManagerFactory < handle
    % A class defining MATLAB PeerModel Variable Manager
    % 

    % Copyright 2013-2014 The MathWorks, Inc.

    % Property Definitions:

    % Events
    events
       ManagerFocusGained;  % Sent from the factory when a manager gains focus
       ManagerFocusLost;  % Sent from the factory when manager loses focus
    end
    
    properties (Constant)
        % PeerModelChannel
        PeerModelChannel = '/VariableEditorManager';

        % Force New Instance
        % Used to force creation of a new instance for testing purposes
        ForceNewInstance = 'force_new_instance';
    end

    properties (SetObservable=false, SetAccess='protected', GetAccess='public', Dependent=false, Hidden=false)
        PeerManager;
        Channel = internal.matlab.variableeditor.peer.PeerManagerFactory.PeerModelChannel;
    end
    
    % Peer Listener Properties
    properties (SetObservable=false, SetAccess='protected', GetAccess='public', Dependent=false, Hidden=false)
        PeerEventListener;
        PropertySetListener;
    end %properties
    
    % Constructor
    methods(Access='protected')
        function this = PeerManagerFactory()
            Root = [internal.matlab.variableeditor.peer.PeerManagerFactory.PeerModelChannel '_Root'];
            this.PeerManager = internal.matlab.variableeditor.peer.PeerManager(internal.matlab.variableeditor.peer.PeerManagerFactory.PeerModelChannel, Root, true);

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
                        case 'CreateManager' % Fired to start a server peer manager
                            this.logDebug('PeerManagerFactory','handlePeerEvent','CreateManager');
                            this.createInstance(ed.EventData.channel,ed.EventData.ignoreUpdates);
                        case 'DeleteManager' % Fired to remove a server peer manager
                            this.logDebug('PeerManagerFactory','handlePeerEvent','DeleteManager');
                            if this.getManagerInstances.isKey(ed.EventData.channel)
                                manager = this.createInstance(ed.EventData.channel,false);
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
    
    % Protected Static methods
    methods(Static, Access='public')
        function inupdate = inFocusUpdate(varargin)
            persistent inUpdateChain;
            if isempty(inUpdateChain)
                inUpdateChain = false;
            end
            
            if (nargin > 0)
                inUpdateChain = varargin{1};
            end
            
            inupdate = inUpdateChain;
        end
        
        function obj = getSetFocusedManager(varargin)
            mlock; % Keep persistent variables until MATLAB exits
            persistent focusedManager;

            if internal.matlab.variableeditor.peer.PeerManagerFactory.inFocusUpdate
                return;
            end
            
            obj = focusedManager;
            oldManager = focusedManager;

            % Short circuit if old value is same as new value or no value
            % passed in.  To prevent infinte loop.
            if nargin == 0 || ...
               isequal(focusedManager, varargin{1}) || ...
               (~isempty(varargin{1}) && ~isa(varargin{1}, 'internal.matlab.variableeditor.peer.PeerManager')) || ...
               (~isempty(varargin{1}) && strcmp(varargin{1}.Channel,internal.matlab.variableeditor.peer.PeerManagerFactory.PeerModelChannel))
                return;
            end

            newManager = varargin{1};

            % Factory Instance
            factoryInstance = internal.matlab.variableeditor.peer.PeerManagerFactory.getInstance();

            % Fire event when manager loses focus
            if ~isempty(focusedManager)
                eventdata = internal.matlab.variableeditor.ManagerEventData;
                eventdata.Manager = focusedManager;
                factoryInstance.notify('ManagerFocusLost',eventdata);
            end

            focusedManager = varargin{1};
            channel = '';

            % Fire event when manager gainsfocus
            if ~isempty(newManager)
                eventdata = internal.matlab.variableeditor.ManagerEventData;
                eventdata.Manager = newManager;
                factoryInstance.notify('ManagerFocusGained',eventdata);
                channel = newManager.Channel;
            end

            % Send a peer event with the new manager channel
            factoryInstance.PeerManager.setProperty('FocusedManager', channel);

            % Setting these must happed at the end because they will call
            % back into this method but the short circuit at the beginning
            % should prevent an infinite loop
            if ~isempty(oldManager) && isvalid(oldManager)
                internal.matlab.variableeditor.peer.PeerManagerFactory.inFocusUpdate(true);
                oldManager.HasFocus = false;
                internal.matlab.variableeditor.peer.PeerManagerFactory.inFocusUpdate(false);
            end
            if ~isempty(newManager)
                internal.matlab.variableeditor.peer.PeerManagerFactory.inFocusUpdate(true);
                newManager.HasFocus = true;
                internal.matlab.variableeditor.peer.PeerManagerFactory.inFocusUpdate(false);
            end
        end
        
        function setFocusedManager(manager)
            internal.matlab.variableeditor.peer.PeerManagerFactory.getSetFocusedManager(manager);
        end
    end

    % Public Static Methods
    methods(Static, Access='public')
        % getInstance
        function obj = getInstance(varargin)
            mlock; % Keep persistent variables until MATLAB exits
            persistent managerInstance;
            if isempty(managerInstance) || (nargin>0 && strcmpi(varargin{1},internal.matlab.variableeditor.peer.PeerManager.ForceNewInstance))
                managerInstance = internal.matlab.variableeditor.peer.PeerManagerFactory();
            end
            obj = managerInstance;
        end
        
        function obj = createManager(Channel, IgnoreUpdates)
            factoryInstance = internal.matlab.variableeditor.peer.PeerManagerFactory.getInstance();
            factoryInstance.logDebug('PeerManagerFactory','createManager','','channel',Channel,'IgnoreUpdate',IgnoreUpdates);
            obj = internal.matlab.variableeditor.peer.PeerManagerFactory.createInstance(Channel, IgnoreUpdates);
        end

        function obj = getManagerInstances(newManagerInstances)
            mlock; % Keep persistent variables until MATLAB exits
            persistent managerInstances;
            
            % Factory Instance
            factoryInstance = internal.matlab.variableeditor.peer.PeerManagerFactory.getInstance();

            if nargin > 0
                managerInstances = newManagerInstances;
                factoryInstance.logDebug('PeerManagerFactory','getManagerInstances','set');
                keys = managerInstances.keys();
                managerJSON = ['[' sprintf('"%s",',keys{:})];
                managerJSON(end) = ']';

                factoryInstance.PeerManager.setProperty('Managers', managerJSON);
            elseif isempty(managerInstances)
                factoryInstance.logDebug('PeerManagerFactory','getManagerInstances','initial creation');
                managerInstances = containers.Map();
            else
                factoryInstance.logDebug('PeerManagerFactory','getManagerInstances','get');
            end
            
            obj = managerInstances;
        end
        
        function obj = createInstance(Channel, IgnoreUpdates)
            mlock; % Keep persistent variables until MATLAB exits
            persistent deleteListeners; %#ok<PUSE>

            % Make sure Factory is started
            factoryInstance = internal.matlab.variableeditor.peer.PeerManagerFactory.getInstance();

            managerInstances = internal.matlab.variableeditor.peer.PeerManagerFactory.getManagerInstances();
            if isempty(deleteListeners)
                deleteListeners = containers.Map();
            end

            if ~isKey(managerInstances, Channel)
                Root = [Channel '_Root'];
                managerInstance = ...
                       internal.matlab.variableeditor.peer.PeerManager(...
                                             Channel, Root, IgnoreUpdates);
                managerInstances(Channel) = managerInstance;
                deleteListeners(Channel) = event.listener(managerInstance,...
                    'ObjectBeingDestroyed',...
                    @(es,ed) (internal.matlab.variableeditor.peer.PeerManagerFactory.getManagerInstances(managerInstances.remove(Channel))));

                internal.matlab.variableeditor.peer.PeerManagerFactory.getManagerInstances(managerInstances);
            end

            % Send event for the manager creation
            if (internal.matlab.variableeditor.peer.PeerUtils.isTestingOn)
               internal.matlab.variableeditor.peer.PeerUtils.sendPeerEvent(factoryInstance.PeerManager.getRoot(), 'ManagerCreated', 'Channel', Channel); 
            end            

            % Return the new manager instances
            obj = managerInstances(Channel);
        end
        
        function startup()
            % Makes sure the peer manager for the variable editor exists
            [~]=internal.matlab.variableeditor.peer.PeerManagerFactory.getInstance();
        end

        function obj = getFocusedManager()
            % Get the currently focused manager
            obj = internal.matlab.variableeditor.peer.PeerManagerFactory.getSetFocusedManager();
        end
    end
end
