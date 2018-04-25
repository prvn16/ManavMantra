classdef (Sealed) PeerModelManagers < handle
    % Peer Model Managers (singleton, one per MATLAB session).  For
    % internal use only.
    %
    % Constructor:
    %   N/A
    %
    % Properties:
    %   N/A
    %
    % Static Methods:
    %   <a href="matlab:help peermodel.internal.PeerModelManagers.getClientManager">getClientManager</a>
    %   <a href="matlab:help peermodel.internal.PeerModelManagers.getServerManager">getServerManager</a>
    %   <a href="matlab:help peermodel.internal.PeerModelManagers.deleteManager">deleteManager</a>
    %   <a href="matlab:help peermodel.internal.PeerModelManagers.hasNodeById">hasNodeById</a>
    %   <a href="matlab:help peermodel.internal.PeerModelManagers.getNodeById">getNodeById</a>
    %
    % See also peermodel.internal.PeerModelManagerServerMode, peermodel.internal.PeerModelManagerClientMode

    % Author(s): Rong Chen
    % Revised:
    % Copyright 2010-2011 The MathWorks, Inc.
    % $Revision: 1.1.4.1 $ $Date: 2014/03/26 02:40:43 $
    
    properties (SetAccess = private, Hidden)
        % Peer Node hash map
        Map
    end
    
    methods (Access = private)
        
        function this = PeerModelManagers()
            % Constructor.
            this.Map = containers.Map();
        end
        
    end
    
    methods (Static)
        
        function manager = getClientManager(channel)
            % Create or get a peer model manager in the client/slave mode.
            % You must specify the channel name (namespace).
            %
            % Input arguments:
            %
            %   "channel" must be a string
            %
            %   if the channel already exists, its manager is returned.
            %   Otherwise, the channel is created and its manager is
            %   returned.
            %
            % Example:
            %   peermodel.internal.PeerModelManagers.getClientManager('MyChannel')
            manager = peermodel.internal.PeerModelManagerClientMode(channel);
        end
        
        function manager = getServerManager(channel)
            % Create or get a peer model manager in the server/master mode.
            % You must specify the channel name (namespace).
            %
            % Input arguments:
            %
            %   "channel" must be a string
            %
            %   if the channel already exists, its manager is returned.
            %   Otherwise, the channel is created and its manager is
            %   returned.
            %
            % Example:
            %   mgr = peermodel.internal.PeerModelManagers.getServerManager('MyChannel');
            manager = peermodel.internal.PeerModelManagerServerMode(channel);
        end
        
        function deleteManager(manager)
            % Delete a peer model manager in the server mode.  All the peer
            % nodes in this channel will be destroyed as well as the peer
            % model on the client side. 
            %
            % Input must be a PeerModelManagerServerMode object.
            %
            % Example:
            %   peermodel.internal.PeerModelManagers.deleteManager(manager);
            if isa(manager, 'peermodel.internal.PeerModelManagerServerMode')
                javaMethodEDT('cleanup','com.mathworks.peermodel.PeerModelManagers',manager.Channel);
                delete(manager);
            else
                error('You can only delete a peer model manager in the server/master mode!')
            end
        end
        
        function value = getNodeById(key)
            % find a peer node based on the specified id
            %  node = peermodel.internal.PeerModelManagers.getNodeById(id)
            managers = peermodel.internal.PeerModelManagers.getInstance();
            try
                value = managers.Map(key);
            catch ME
                throw(ME)
            end
        end
        
        function value = hasNodeById(key)
            % check whether there is a peer node based on the specified id
            %  existed = peermodel.internal.PeerModelManagers.hasNodeById(id)
            managers = peermodel.internal.PeerModelManagers.getInstance();
            value = managers.Map.isKey(key);
        end
        
    end
    
    methods (Static, Access = private)
        
        function singleObj = getInstance()
            % singleton
            mlock
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj)
                localObj = peermodel.internal.PeerModelManagers;
            end
            singleObj = localObj;
        end
        
    end
        
    methods (Static, Hidden)
        
        function registerPeerNode(key, value)
            managers = peermodel.internal.PeerModelManagers.getInstance();
            managers.Map(key) = value;
        end
        
        function unregisterPeerNode(key)
            managers = peermodel.internal.PeerModelManagers.getInstance();
            if isKey(managers.Map, key)
                remove(managers.Map, key);
            end
        end
        
        function resetPeerNodeRegistry()
            managers = peermodel.internal.PeerModelManagers.getInstance();
            managers.Map = containers.Map();
        end
        
        function value = getPeerNodeRegistrySize()
            managers = peermodel.internal.PeerModelManagers.getInstance();
            value = managers.Map.Count;
        end
        
    end
    
end