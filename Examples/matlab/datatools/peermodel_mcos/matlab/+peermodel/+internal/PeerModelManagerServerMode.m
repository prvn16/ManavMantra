classdef (Sealed) PeerModelManagerServerMode < peermodel.internal.PeerModelManager
    % Peer Model Manager in the Server Mode. For internal use only.
    %
    % Constructor:
    %   N/A
    %
    % Properties:
    %   <a href="matlab:help peermodel.internal.PeerModelManager.Channel">Channel</a>    
    %   <a href="matlab:help peermodel.internal.PeerModelManager.SyncEnabled">SyncEnabled</a>    
    %
    % Methods:
    %   <a href="matlab:help peermodel.internal.PeerModelManagerServerMode.createRoot">createRoot</a>
    %   <a href="matlab:help peermodel.internal.PeerModelManagerServerMode.deleteRoot">deleteRoot</a>
    %   <a href="matlab:help peermodel.internal.PeerModelManagerServerMode.move">move</a>
    %
    %   <a href="matlab:help peermodel.internal.PeerModelManager.hasRoot">hasRoot</a>
    %   <a href="matlab:help peermodel.internal.PeerModelManager.getRoot">getRoot</a>
    %
    %   <a href="matlab:help peermodel.internal.PeerModelManager.hasNodeById">hasNodeById</a>
    %   <a href="matlab:help peermodel.internal.PeerModelManager.getNodeById">getNodeById</a>
    %   <a href="matlab:help peermodel.internal.PeerModelManager.getNodeByType">getNodeByType</a>
    %   <a href="matlab:help peermodel.internal.PeerModelManager.getNodeByProperty">getNodeByProperty</a>
    %
    % See also peermodel.internal.PeerNodeServerMode

    % Author(s): Rong Chen
    % Revised:
    % Copyright 2010-2011 The MathWorks, Inc.
    % $Revision: 1.1.4.1 $ $Date: 2014/03/26 02:40:42 $
    
    methods (Access = {?peermodel.internal.PeerModelManagers})
        
        function this = PeerModelManagerServerMode(channel)
            % create or get the manager of the channel
            this.javaManager = javaMethodEDT('getServerInstance','com.mathworks.peermodel.PeerModelManagers',channel);
            % set channel
            this.Channel = channel;
        end
        
    end
    
    methods
    
        %% Root operations
        function root = createRoot(this, type, varargin)
            % create the root in the following manner:
            %
            %  root = mgr.createRoot(type)
            %  root = mgr.createRoot(type, struct)
            %  root = mgr.createRoot(type, prop1, value1, prop2, value2, ...)
            if this.javaManager.hasRoot()
                error('root already exists!  Use "deleteRoot" to delete everything in the peer model before using "setRoot"')
            else
                ni = nargin-1;
                if ni == 1
                    % type only
                    root = peermodel.internal.PeerNodeServerMode(this.javaManager.setRoot(type));
                elseif ni == 2
                    % type and struct
                    hashmap = peermodel.internal.Utility.convertStructToJavaMap(varargin{1});
                    root = peermodel.internal.PeerNodeServerMode(this.javaManager.setRoot(type, hashmap));
                else
                    % type and PV pairs
                    if rem(ni-1,2)~=0,
                        error('Use name/value pairs to specify property values.')
                    end
                    for ct=1:2:(ni-1)
                        if ~ischar(varargin{ct})
                            error('Property name must be a string.')
                        end
                    end
                    structure = struct(varargin{:});
                    hashmap = peermodel.internal.Utility.convertStructToJavaMap(structure);
                    root = peermodel.internal.PeerNodeServerMode(this.javaManager.setRoot(type, hashmap));
                end
            end
            peermodel.internal.PeerModelManagers.registerPeerNode(root.Id, root);
        end
        
        function deleteRoot(this)
            % delete the root
            %    mgr.deleteRoot()
            if this.javaManager.hasRoot()
                id = char(this.javaManager.getRoot().getId());
                if peermodel.internal.PeerModelManagers.hasNodeById(id)
                    peermodel.internal.PeerModelManagers.unregisterPeerNode(id);
                end
                this.javaManager.getRoot().remove();
            end
        end
        
        %% move
        function move(this, child, parent, varargin)
            % Move a peer node to a new parent peer node in this peer model
            %  mgr.movePeerNode(child, parent)
            %  mgr.movePeerNode(child, parent, index)
            if nargin == 3
                this.javaManager.move(child.Peer, parent.Peer);
            else
                index = max(1,min(varargin{1},parent.getChildrenNumber()+1));
                this.javaManager.move(child.Peer, parent.Peer, index-1);
            end
        end
        
    end
       
end