classdef (Abstract) Component < matlab.ui.internal.toolstrip.base.Node & matlab.ui.internal.toolstrip.base.PeerInterface
    % Base class for MCOS toolstrip components.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Dependent, Access = public)
        % Property "Tag": 
        %
        %   The tag of a toolstrip component.  
        %   It is a string and the default value is ''.
        %   It is optional and writable.
        %
        %   Specify a unique tag in the toolstrip hierarchy if you want to
        %   use the "find" or "get" method to locate the component later.
        Tag
    end
    
    properties (Access = protected)
        Type
        TagPrivate = ''
        WidgetPropertyMap_FromMCOSToPeer
        WidgetPropertyMap_FromPeerToMCOS
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Get/Set
        % Tag
        function value = get.Tag(this)
            % GET function for Tag property.
            value = this.TagPrivate;
        end
        function set.Tag(this, value)
            % SET function for Tag property.
            value = matlab.ui.internal.toolstrip.base.Utility.hString2Char(value);
            if ~ischar(value)
                error(message('MATLAB:toolstrip:general:invalidTag'));
            end
            this.TagPrivate = value;
            this.setPeerProperty('tag',value);
        end
        
        %% Overload "delete" method
        function delete(this)
            % Delete this component and all the children.
            %
            % Example:
            %   panel = matlab.ui.internal.toolstrip.Panel
            %   btn = matlab.ui.internal.toolstrip.Button('Submit')
            %   panel.add(btn)
            %   btn.delete
            
            % Remove itself as a child from the parent node if it exists.
            parent = this.Parent;
            if ~isempty(parent) && isvalid(parent)
                siblings = parent.Children;
                k = length(siblings);
                while (k > 0) && (siblings(k) ~= this)
                    k = k-1;
                end
                parent.Children(k) = [];
            end
            % remove all the children from this component.
            % We have to do it from the last child to the first child
            % because the order of the children is kept intact in that way. 
            while ~isempty(this.Children)
                %tree_remove(this, this.Children(end));
                this.Children(end).Parent = [];
                if isvalid(this.Children(end))
                    delete(this.Children(end));
                end
                this.Children(end) = [];
            end
            % delete peer node
            this.destroyPeer();
        end
        
    end
    
    methods (Hidden)
        
        function value = getIndex(this)
            %   Return the index of the object in the parent container.  It
            %   is a positive integer when the object has a hosting
            %   container, otherwise it is [].
            %
            %   Example:
            %       tabgroup = matlab.ui.internal.toolstrip.TabGroup()
            %       tab1 = matlab.ui.internal.toolstrip.Tab('title1')
            %       tab2 = matlab.ui.internal.toolstrip.Tab('title2')
            %       tabgroup.add(tab1)
            %       tabgroup.add(tab2)
            %       tab1.getIndex() % return 1
            %       tabgroup.remove(tab1)
            %       tab1.getIndex() % return []
            value = [];
            if ~isempty(this.Parent)
                for ct=1:length(this.Parent.Children)
                    if this == this.Parent.Children(ct)
                        value = ct;
                        break;
                    end
                end
            end
        end
        
    end
    
    %% common methods
    methods (Access = protected)
        
        function [mcos, peer] = getWidgetPropertyNames_Component(this) %#ok<MANU>
            % provide MCOS and peer node name map for widget properties
            mcos = {'TagPrivate'};
            peer = {'tag'};
        end
        
        function properties = getWidgetProperties(this)
            % construct structure from current MCOS widget properties and
            % send it over to peer node constructor.  Called when
            % constructing peer node during rendering.
            keys = this.WidgetPropertyMap_FromPeerToMCOS.keys();
            values = this.WidgetPropertyMap_FromPeerToMCOS.values();
            for ct=1:length(keys)
                properties.(keys{ct}) = this.(values{ct});
            end
        end
        
        function OK = isChild(this, obj)
            % check whether obj is a child of this object
            OK = false;
            for ct=1:length(this.Children)
                if obj == this.Children(ct)
                    OK = true;
                    break;
                end
            end
        end
        
        function processCustomProperties(this, varargin)
            rules = this.getInputArgumentRules();
            properties = matlab.ui.internal.toolstrip.base.Utility.processProperties(rules, varargin{:});
            props = fieldnames(properties);
            for ct=1:length(props)
                this.(props{ct}) = properties.(props{ct});
            end
        end
        
    end
    
    %% hidden methods
    methods (Hidden)
        
        function peer = getPeer(this)
            peer = this.Peer;
        end
        
        function id = getId(this)
            if hasPeerNode(this)
                id  = char(this.Peer.getId());
            else
                id = '';
            end
        end
        
        function type = getType(this)
            type = this.Type;
        end
        
        function render(this, channel, parent, varargin)
            % Method "render"
            %
            %   create the widget peer node (at the orphan root) and add it
            %   to its parent (move to parent node).  There is no action
            %   node. There is no children node under a control. 
            %
            %   Overloaded by Container and Control subclasses
            
            % create peer node if it does not exist (orphan root)
            if ~hasPeerNode(this)
                % create peer node
                this.PeerModelChannel = channel;
                widget_properties = this.getWidgetProperties();
                this.createPeer(widget_properties);
            end
            % move this peer node to parent
            this.moveToTarget(parent,varargin{:});
        end
    
    end
    
    %% abstract methods
    methods (Abstract, Access = protected)
        getInputArgumentRules(this)
        buildWidgetPropertyMaps(this)
    end
    
end

