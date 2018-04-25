classdef (Abstract) PeerInterface < handle
    % Base class for MCOS toolstrip components.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    %% -----------  User-invisible properties --------------------
    properties (GetAccess = protected, SetAccess = protected)
        % Peer Node
        Peer = []
        % Source
        PropertySetSource
        % 
        PeerModelChannel = ''
    end

    properties (Abstract, Access = protected)
        % Peer Node
        Type
    end
    
    properties (Access = protected)
        % Listeners for view events
        PeerEventListener
        PropertySetListener
    end
    
    methods (Access = protected)
        
        % Create toolstrip peer node and attach it to the orphan root.
        % Create action peer node and attach it to the action root.  We
        % always create a peer node at the orphan root because of Swing
        % support.  otherwise, we have to add "childadded" listener to
        % every node
        function createPeer(this, props_struct)
            type = this.Type;
            if strcmp(type,'Action')
                manager = com.mathworks.peermodel.PeerModelManagers.getInstance(this.PeerModelChannel);
                parent_node = manager.getRoot();
            else
                manager = com.mathworks.peermodel.PeerModelManagers.getInstance(this.PeerModelChannel);
                parent_node = manager.getByType('OrphanRoot').get(0);
            end
            % prepare property value pairs
            props_hash = matlab.ui.internal.toolstrip.base.Utility.convertFromStructureToHashmap(props_struct);
            % create peer node and put it into orphan tree
            this.Peer = parent_node.addChild(type, props_hash);
            % add listeneer to peer node event coming from client node
            this.PropertySetListener = addlistener(this.Peer, 'propertySet', @(event, data) PropertySetCallback(this, event, data));
            this.PeerEventListener = addlistener(this.Peer, 'peerEvent', @(event, data) PeerEventCallback(this, event, data));
            % set source is MCOS
            this.PropertySetSource = java.util.HashMap();
            this.PropertySetSource.put('source','MCOS');
        end
        
        % Destroy peer node and all its children
        function destroyPeer(this)
            if ~isempty(this.Peer)
                this.Peer.destroy();
            end
        end
        
        % Move peer node
        function moveToTarget(this,target,varargin)
            %%
            manager = com.mathworks.peermodel.PeerModelManagers.getInstance(this.PeerModelChannel);
            if ischar(target)
                % no op for Toolstrip target
                switch target
                    case 'PopupList'
                        manager.move(this.Peer, manager.getByType('PopupRoot').get(0));
                    case 'GalleryPopup'
                        manager.move(this.Peer, manager.getByType('GalleryPopupRoot').get(0));
                    case 'GalleryFavoriteCategory'
                        manager.move(this.Peer, manager.getByType('GalleryFavoriteCategoryRoot').get(0));
                    case 'QuickAccessBar'
                        manager.move(this.Peer, manager.getByType('QABRoot').get(0));
                    case 'Toolstrip'
                        manager.move(this.Peer, manager.getByType('ToolstripRoot').get(0));
                    case 'TabGroup'
                        manager.move(this.Peer, manager.getByType('TabGroupRoot').get(0));
                    case 'QuickAccessGroup'
                        manager.move(this.Peer, manager.getByType('QAGroupRoot').get(0));
                end
            else
                if nargin == 2
                    current_parent = this.Peer.getParent();
                    if current_parent~=target.Peer
                        % move only when necessary
                        manager.move(this.Peer,target.Peer);
                    end
                else
                    manager.move(this.Peer,target.Peer,varargin{1}-1);
                end
            end
        end
        
        % Move peer node
        function moveToOrphanRoot(this)
            %%
            manager = com.mathworks.peermodel.PeerModelManagers.getInstance(this.PeerModelChannel);
            % target is already a peer node
            manager.move(this.Peer,manager.getByType('OrphanRoot').get(0));
        end
        
        % Get peer node property
        function matlab_value = getPeerProperty(this, property)
            java_value = this.Peer.getProperty(property);
            matlab_value = matlab.ui.internal.toolstrip.base.Utility.convertFromJavaToMatlab(java_value);
        end
        
        % Set peer node property
        function setPeerProperty(this, property, matlab_value)
            % skip when the peer node does not exist
            if ~isempty(this.Peer)
                % convert value into java format
                java_value = matlab.ui.internal.toolstrip.base.Utility.convertFromMatlabToJava(matlab_value);
                % set peer node property
                this.Peer.setProperty(property, java_value, this.PropertySetSource);
            end
        end
        
        % Dispatch peer event from server to client
        function dispatchEvent(this, structure)
            hashmap = matlab.ui.internal.toolstrip.base.Utility.convertFromStructureToHashmap(structure);
            if ~isempty(this.Peer)
                this.Peer.dispatchEvent('peerEvent',this.Peer,hashmap);
            end
        end
        
        function PropertySetCallback(this,src,data)
            % no op
        end
        
        function PeerEventCallback(this,src,data)
            % no op
        end
        
        function value = hasPeerNode(this)
            value = ~isempty(this.Peer);
        end
        
        function value = getPeerModelChannel(this)
            value = this.PeerModelChannel;
        end
        
    end
    
end

