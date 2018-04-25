classdef (Sealed) PeerNodeServerMode < peermodel.internal.PeerNode
    % Peer Node in the Server Mode.
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
    %   <a href="matlab:help peermodel.internal.PeerNodeServerMode.addChild">addChild</a>
    %   <a href="matlab:help peermodel.internal.PeerNodeServerMode.deleteChild">deleteChild</a>
    %   <a href="matlab:help peermodel.internal.PeerNodeServerMode.detach">detach</a>
    %   <a href="matlab:help peermodel.internal.PeerNodeServerMode.reattach">reattach</a>
    %
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
    %   <a href="matlab:help peermodel.internal.PeerNode.getDescendant>getDescendant</a>
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
    %   <a href="matlab:help peermodel.internal.PeerNode.PropertySet">PropertySet</a>            
    %   <a href="matlab:help peermodel.internal.PeerNode.PropertyDeleted">PropertyDeleted</a>            
    %   <a href="matlab:help peermodel.internal.PeerNode.PeerEvent">PeerEvent</a>            
    %
    % See also peermodel.internal.PeerModelManagerServerMode
    
    % Author(s): Rong Chen
    % Copyright 2012-2013 The MathWorks, Inc.
    % $Revision: 1.1.4.1 $ $Date: 2014/03/26 02:40:46 $
    
    properties (Access = protected)
        % Listener to Java PeerEvent event
        DestroyedListener
        % BeingDeletedBy
        BeingDeletedFromJava = false
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods (Access = {?peermodel.internal.PeerModelManagerServerMode})
        
        %% Constructor
        function this = PeerNodeServerMode(argument)
            if isjava(argument)
                % called by PeerModelManagerServerMode
                % input argumenet is the java root node
                this.Peer = argument;
                this.Id = char(argument.getId());
                this.Type = char(argument.getType());
                this.addListeners();
            else
                % called by addChild from a parent of PeerNodeServerMode
                % input argumenet is the type
                this.Type = argument;
            end
        end
        
    end
    
    methods
        
        %% Create child node
        function child = addChild(this, type, varargin)
            % create a child node in the following manner:
            %
            % Append:
            %  child = node.addChild(type)
            %  child = node.addChild(type, struct)
            %  child = node.addChild(type, prop1, value1, prop2, value2, ...)
            %
            % Insert:
            %  child = node.addChild(type, index)
            %  child = node.addChild(type, index, struct)
            %  child = node.addChild(type, index, prop1, value1, prop2, value2, ...)

            % create child MCOS object
            child = peermodel.internal.PeerNodeServerMode(type);
            % create peer node
            ni = nargin - 2;
            if ni==0
                % type only
                child.Peer = this.Peer.addChild(type);
            else
                if isnumeric(varargin{1})
                    index = max(1,min(varargin{1}, this.Peer.getNumberOfChildren()+1));
                    if ni==1
                        % type, index
                        child.Peer = this.Peer.addChild(type, index-1);                            
                    elseif isstruct(varargin{2})
                        % type, index, struct
                        props_hash = peermodel.internal.Utility.convertStructToJavaMap(varargin{2});
                        child.Peer = this.Peer.addChild(type, props_hash, index-1);
                    else
                        % type, index, PV pair
                        if rem(ni-1,2)~=0,
                            error('Use name/value pairs to specify property values.')
                        end
                        for ct=1:2:(ni-1)
                            if ~ischar(varargin{ct+1})
                                error('Property name must be a string.')
                            end
                        end
                        structure = struct(varargin{2:end});
                        props_hash = peermodel.internal.Utility.convertStructToJavaMap(structure);
                        child.Peer = this.Peer.addChild(type, props_hash, index-1);
                    end
                else
                    if isstruct(varargin{1})
                        % type, struct
                        props_hash = peermodel.internal.Utility.convertStructToJavaMap(varargin{1});
                        child.Peer = this.Peer.addChild(type, props_hash);
                    else
                        % type, PV pair
                        if rem(ni,2)~=0,
                            error('Use name/value pairs to specify property values.')
                        end
                        for ct=1:2:ni
                            if ~ischar(varargin{ct})
                                error('Property name must be a string.')
                            end
                        end
                        structure = struct(varargin{:});
                        props_hash = peermodel.internal.Utility.convertStructToJavaMap(structure);
                        child.Peer = this.Peer.addChild(type, props_hash);
                    end
                end
            end
            % set id
            child.Id = char(child.Peer.getId());
            % register
            peermodel.internal.PeerModelManagers.registerPeerNode(child.Id, child);
            % add listeneer to peer node event coming from client node
            child.addListeners();
        end
        
        %% Delete child node
        function deleteChild(this, index)
            % Delete a child node based on its index:
            %    node.deleteChild(2)
            delete(this.Children(index));
        end
        
        %% Detach child node
        function detach(this)
            % Detach from parent:
            %    node.detach()
            this.Peer.detach();
        end
        
        %% Detach child node
        function reattach(this, index)
            % Re-attach to parent:
            %    node.reattach()
            %    node.reattach(index)
            if nargin == 1
                this.Peer.reattach();
            else
                this.Peer.reattach(index-1);
            end
        end
        
        %% Overload "delete" method
        function delete(this)
            if peermodel.internal.PeerModelManagers.hasNodeById(this.Id)
                peermodel.internal.PeerModelManagers.unregisterPeerNode(this.Id);
            end
            this.PropertySetListener = [];
            this.PeerEventListener = [];
            this.DestroyedListener = [];
            if this.BeingDeletedFromJava
%                 disp('java peer node destroyed by parent!')
            else
                if ~isempty(this.Peer)
                    this.Peer.destroy();
                end
%                 disp('java peer node destroyed by itself!')
            end
        end
        
    end
    
    methods (Access = protected)

        function addListeners(this)
            addListeners@peermodel.internal.PeerNode(this);
            this.DestroyedListener = addlistener(this.Peer, 'destroyed', @(event, data) DestroyedCallback(this, event, data));            
        end
        
        function DestroyedCallback(this,src,data) %#ok<*INUSD>
            this.BeingDeletedFromJava = true;
            delete(this);
        end
        
    end
    
end

