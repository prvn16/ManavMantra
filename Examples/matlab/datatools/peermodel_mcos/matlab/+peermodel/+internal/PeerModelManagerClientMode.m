classdef (Sealed) PeerModelManagerClientMode < peermodel.internal.PeerModelManager
    % Peer Model Manager in the Client Mode. For internal use only.
    %
    % Constructor:
    %   N/A
    %
    % Properties:
    %   <a href="matlab:help peermodel.internal.PeerModelManager.Channel">Channel</a>    
    %   <a href="matlab:help peermodel.internal.PeerModelManager.SyncEnabled">SyncEnabled</a>    
    %
    % Methods:
    %   <a href="matlab:help peermodel.internal.PeerModelManager.hasRoot">hasRoot</a>
    %   <a href="matlab:help peermodel.internal.PeerModelManager.getRoot">getRoot</a>
    %
    %   <a href="matlab:help peermodel.internal.PeerModelManager.hasNodeById">hasNodeById</a>
    %   <a href="matlab:help peermodel.internal.PeerModelManager.getNodeById">getNodeById</a>
    %   <a href="matlab:help peermodel.internal.PeerModelManager.getNodeByType">getNodeByType</a>
    %   <a href="matlab:help peermodel.internal.PeerModelManager.getNodeByProperty">getNodeByProperty</a>
    %
    % Events:
    %   <a href="matlab:help peermodel.internal.PeerModelManagerClientMode.RootCreated">RootCreated</a>
    %   <a href="matlab:help peermodel.internal.PeerModelManagerClientMode.RootDeleted">RootDeleted</a>
    %   <a href="matlab:help peermodel.internal.PeerModelManagerClientMode.ChildMoved">ChildMoved</a>            
    %
    % See also peermodel.internal.PeerNodeClientMode

    % Author(s): Rong Chen
    % Revised:
    % Copyright 2010-2011 The MathWorks, Inc.
    % $Revision: 1.1.4.1 $ $Date: 2014/03/26 02:40:41 $
    
    properties (Access = private)
        % Peer event listeners
        RootCreatedListener
        RootDeletedListener
        ChildMovedListener
    end
    
    events
        RootCreated
        RootDeleted
        ChildMoved
    end
    
    methods (Access = {?peermodel.internal.PeerModelManagers})
        
        function this = PeerModelManagerClientMode(channel)
            % create or get the manager of the channel
            this.javaManager = javaMethodEDT('getClientInstance','com.mathworks.peermodel.PeerModelManagers',channel);
            % set channel
            this.Channel = channel;
            % add listeners
            this.addListeners();
        end
        
    end
    
    methods (Access = private)
        
        function addListeners(this)
            this.RootCreatedListener = addlistener(this.javaManager, 'rootSet', @(event, data) RootCreatedCallback(this, event, data));            
            this.RootDeletedListener = addlistener(this.javaManager, 'rootUnset', @(event, data) RootDeletedCallback(this, event, data));            
            this.ChildMovedListener = addlistener(this.javaManager, 'childMoved', @(event, data) ChildMovedCallback(this, event, data));            
        end
        
        function RootCreatedCallback(this,src,data) %#ok<*INUSD>
            id = char(data.getTarget().getId());
            if ~peermodel.internal.PeerModelManagers.hasNodeById(id)
                root = peermodel.internal.PeerNodeClientMode(data.getTarget());
                peermodel.internal.PeerModelManagers.registerPeerNode(id, root);
            end
            eventdata = peermodel.internal.PeerModelEventData(struct('Id', id));
            this.notify('RootCreated', eventdata);
        end
        
        function RootDeletedCallback(this,src,data)
            id = char(data.getTarget().getId());
            eventdata = peermodel.internal.PeerModelEventData(struct('Id', id));
            this.notify('RootDeleted',eventdata);
            if peermodel.internal.PeerModelManagers.hasNodeById(id)
                root = peermodel.internal.PeerModelManagers.getNodeById(id);
                peermodel.internal.PeerModelManagers.unregisterPeerNode(id);
                delete(root);
            end
        end
        
        function ChildMovedCallback(this,src,data)
            structure = struct('Id',char(data.getTarget().getId()),...
                'OldParentId', char(data.getData.get('oldParent').getId()), ...
                'NewParentId', char(data.getData.get('newParent').getId()), ...
                'OldIndex', data.getData.get('oldIndex'), ...
                'NewIndex', data.getData.get('newIndex'));
            eventdata = peermodel.internal.PeerModelEventData(structure);            
            this.notify('ChildMoved',eventdata);
        end
        
    end
    
end