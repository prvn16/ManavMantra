classdef (Sealed) PeerNodeClientMode < peermodel.internal.PeerNode
    % Peer Node in the Client Mode.
    %
    % Constructor:
    %   N/A
    %
    % Properties:
    %   <a href="matlab:help peermodel.internal.PeerNode.Id">Id</a>    
    %   <a href="matlab:help peermodel.internal.PeerNode.Type">Type</a>            
    %   <a href="matlab:help peermodel.internal.PeerNode.Parent">Parent</a> 
    %   <a href="matlab:help peermodel.internal.PeerNode.Children">Children</a>        
    %
    % Methods:
    %   <a href="matlab:help peermodel.internal.PeerNode.getProperty">getProperty</a>
    %   <a href="matlab:help peermodel.internal.PeerNode.setProperty">setProperty</a>
    %   <a href="matlab:help peermodel.internal.PeerNode.hasProperty">hasProperty</a>
    %   <a href="matlab:help peermodel.internal.PeerNode.removeProperty">removeProperty</a>
    %
    %   <a href="matlab:help peermodel.internal.PeerNode.getProperties">getProperties</a>
    %   <a href="matlab:help peermodel.internal.PeerNode.setProperties">setProperties</a>
    %   <a href="matlab:help peermodel.internal.PeerNode.removeProperties">removeProperties</a>
    %   <a href="matlab:help peermodel.internal.PeerNode.replaceAllProperties">replaceAllProperties</a>
    %
    %   <a href="matlab:help peermodel.internal.PeerNode.getDescendant">getDescendant</a>
    %   <a href="matlab:help peermodel.internal.PeerNode.hasDescendant">hasDescendant</a>
    %
    %   <a href="matlab:help peermodel.internal.PeerNode.isDetached>isDetached</a>
    %   <a href="matlab:help peermodel.internal.PeerNode.isAncestorDetached">isAncestorDetached</a>
    %   <a href="matlab:help peermodel.internal.PeerNode.getDetachedChildren>getDetachedChildren</a>
    %   <a href="matlab:help peermodel.internal.PeerNode.hasDetachedChildren">hasDetachedChildren</a>
    %
    %   <a href="matlab:help peermodel.internal.PeerNode.dispatchEvent">dispatchEvent</a>
    %
    % Events:
    %   <a href="matlab:help peermodel.internal.PeerNodeClientMode.ChildAdded">ChildAdded</a>
    %   <a href="matlab:help peermodel.internal.PeerNodeClientMode.ChildDeleted">ChildDeleted</a>
    %   <a href="matlab:help peermodel.internal.PeerNode.PropertySet">PropertySet</a>            
    %   <a href="matlab:help peermodel.internal.PeerNode.PropertyDeleted">PropertyDeleted</a>            
    %   <a href="matlab:help peermodel.internal.PeerNode.PeerEvent">PeerEvent</a>            
    %
    % See also peermodel.internal.PeerModelManagerClientMode
    
    % Author(s): Rong Chen
    % Copyright 2012-2017 The MathWorks, Inc.
    % $Revision: 1.1.4.1 $ $Date: 2014/03/26 02:40:45 $
    
    properties (Access = protected)
        ChildAddedListener
        ChildDeletedListener
    end
    
    events
        ChildAdded
        ChildDeleted
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods (Access = {?peermodel.internal.PeerNodeclientMode, ?peermodel.internal.PeerModelManagerClientMode})
        
        %% Constructor
        function this = PeerNodeClientMode(javapeer)
            this.Peer = javapeer;
            this.Id = char(javapeer.getId());
            this.Type = char(javapeer.getType());
            % Create nodes for existing children
            children = this.Peer.getChildren;
            for i = 0 : children.size - 1
                [~] = this.createChildNode(children.get(i));
            end
            this.addListeners();
        end
        
    end
    
    methods (Access = protected)

        function addListeners(this)
            addListeners@peermodel.internal.PeerNode(this);
            this.ChildAddedListener = addlistener(this.Peer, 'childAdded', @(event, data) ChildAddedCallback(this, event, data));            
            this.ChildDeletedListener = addlistener(this.Peer, 'destroyed', @(event, data) ChildDeletedCallback(this, event, data));
        end
        
        function ChildAddedCallback(this,src,data) %#ok<*INUSL>
            childpeer = data.getData().get('child');
            index = data.getData().get('index')+1;
            id = this.createChildNode(childpeer);
            eventdata = peermodel.internal.PeerModelEventData(struct('Id', id, 'Index', index));
            this.notify('ChildAdded',eventdata);
        end
        
        function ChildDeletedCallback(this,src,data)
            childpeer = data.getData().get('child');
            index = data.getData().get('index')+1;
            id = char(childpeer.getId());
            eventdata = peermodel.internal.PeerModelEventData(struct('Id', id, 'Index', index));
            this.notify('ChildDeleted',eventdata);
            if peermodel.internal.PeerModelManagers.hasNodeById(id)
                child = peermodel.internal.PeerModelManagers.getNodeById(id);
                peermodel.internal.PeerModelManagers.unregisterPeerNode(id);
                delete(child);
            end
        end
        
        function id = createChildNode(this, childpeer)
            id = char(childpeer.getId());
            if ~peermodel.internal.PeerModelManagers.hasNodeById(id)
                child = peermodel.internal.PeerNodeClientMode(childpeer);
                peermodel.internal.PeerModelManagers.registerPeerNode(id, child);
            end
        end
        
    end
    
end

