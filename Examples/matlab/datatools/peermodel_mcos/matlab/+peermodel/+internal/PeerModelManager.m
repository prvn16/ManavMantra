classdef (Abstract) PeerModelManager < handle
    % Peer Model Manager Super Class.
    %
    % See also peermodel.internal.PeerModelManagerServerMode, peermodel.internal.PeerModelManagerClientMode

    % Author(s): Rong Chen
    % Revised:
    % Copyright 2010-2011 The MathWorks, Inc.
    % $Revision: 1.1.4.1 $ $Date: 2014/03/26 02:40:40 $
    
    properties (SetAccess = protected, Hidden)
        % Java PeerModelManager object
        javaManager
    end
    
    properties (SetAccess = protected)
        % Property "Channel": 
        %
        %   peer model channel.
        %
        %   Example:
        %       mgr = peermodel.internal.PeerModelManagers.getServerManager('MyChannel');
        %       mgr.Channel % returns MyChannel
        Channel
    end
    
    properties (Dependent)
        % Property "SyncEnabled": 
        %
        %   peer model synchronization state.
        %
        %   Example:
        %       mgr = peermodel.internal.PeerModelManagers.getServerManager('MyChannel');
        %       mgr.SyncEnabled = true
        SyncEnabled
    end
    
    methods
    
        %% Get/Set
        function value = get.SyncEnabled(this)
            value = this.javaManager.isSyncEnabled();
        end
        
        function set.SyncEnabled(this, value)
            this.javaManager.setSyncEnabled(value);
        end
        
        %% Find node
        function value = hasNodeById(this, id)
            % check whether there is a peer node in this channel based on the specified id
            %  existed = mgr.hasNodeById(id)
            value = this.javaManager.hasById(id);
        end
        
        function node = getNodeById(~, key)
            % find a peer node in this channel based on the specified id
            %  node = mgr.getNodeById(id)
            node = peermodel.internal.PeerModelManagers.getNodeById(key);
        end
        
        function nodes = getNodeByType(this, type)
            % find all the peer nodes in this channel based on the specified type
            %  nodes = mgr.getNodeByType(type)
            javacollection = this.javaManager.getByType(type);
            keys = {};
            for ct=1:javacollection.size()
                keys{ct} = char(javacollection.get(ct-1).getId()); %#ok<*AGROW>
            end
            if isempty(keys)
                nodes = [];
            else
                for ct=1:length(keys)
                    nodes(ct) = peermodel.internal.PeerModelManagers.getNodeById(keys{ct});
                end
            end
        end
        
        function nodes = getNodeByProperty(this, prop, value)
            % find all the peer nodes in this channel based on the specified property value pair
            %  nodes = mgr.getNodeByProperty(property, value)
            javavalue = peermodel.internal.Utility.convertValueFromMatlabToJava(value);
            javacollection = this.javaManager.getByProperty(prop, javavalue);
            keys = {};
            for ct=1:javacollection.size()
                keys{ct} = char(javacollection.get(ct-1).getId());
            end
            if isempty(keys)
                nodes = [];
            else
                for ct=1:length(keys)
                    nodes(ct) = peermodel.internal.PeerModelManagers.getNodeById(keys{ct});
                end
            end
        end
        
        %% Root operations
        function value = hasRoot(this)
            % check whether the root node exist
            %  existed = mgr.hasRoot()
            value = this.javaManager.hasRoot();
        end
            
        function root = getRoot(this)
            % get the root node
            %  root = mgr.getRoot()
            if this.javaManager.hasRoot()
                id = char(this.javaManager.getRoot().getId());
                if peermodel.internal.PeerModelManagers.hasNodeById(id)
                    root = peermodel.internal.PeerModelManagers.getNodeById(id);
                else
                    root = peermodel.internal.PeerNode(this.javaManager.getRoot());
                    peermodel.internal.PeerModelManagers.registerPeerNode(root.Id, root);
                end
            else
                root = [];
            end
        end
        
    end
       
end