classdef (Abstract) Container < matlab.ui.internal.toolstrip.base.Component
    % Base class for MCOS toolstrip container components.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    methods
        
        %% Constructor
        function this = Container(type)
            % set type
            this.Type = type;
            % create property maps
            this.buildWidgetPropertyMaps();
        end
        
        %% Add/Remove
        function add(this, component, varargin)
            % Add a child component to this parent container
            if nargin == 2
                % append to the end
                tree_add(this, component);
            else
                % insert at specified indexed location
                tree_insert(this, component, varargin{1});
            end
            % Create child peer node if the parent peer node already exists
            if hasPeerNode(this)
                component.render(this.PeerModelChannel, this, varargin{:});
            end
        end
        
        function remove(this, component)
            % Remove component from the children list of MCOS object
            tree_remove(this, component);
            % Remove component from the children list of Peer Model
            if hasPeerNode(this)
                % Add component as a child to this parent in Peer Model
                component.moveToOrphanRoot();
            end
        end
        
        %% Search
        function obj = find(this, tag)
            % Method "find":
            %
            %   "find(container, tag)": return the first object with
            %   specified tag if it exists anywhere in the container or []
            %   if not found. The container can be toolstrip, tabgroup,
            %   tab, section, panel, column and popuplist.
            %
            %   Example:
            %       ts1 = matlab.ui.internal.toolstrip.Toolstrip('ts1')
            %       tab1 = ts1.addTab('tab1','title1')
            %       tab1.addSection('sec1','title2')
            %       obj = ts1.find('sec1') % returns the handle to the section

            % Process input
            tag = matlab.ui.internal.toolstrip.base.Utility.hString2Char(tag);
            if ischar(tag)
                obj = tree_deep_search(this, tag);
            else
                error(message('MATLAB:toolstrip:container:invalidFind'));
            end
        end
        
        function objs = findAll(this, tag)
            % Method "findAll":
            %
            %   "findAll(container, tag)": return all the objects with
            %   specified tag if they exist anywhere in the container or []
            %   if not found. The container can be toolstrip, tabgroup,
            %   tab, section, panel, column and popuplist.
            %
            %   Example:
            %       ts1 = matlab.ui.internal.toolstrip.Toolstrip('ts1')
            %       tab1 = ts1.addTab('tab1','title1')
            %       tab1.addSection('sec1','title2')
            %       obj = ts1.findAll('sec1') % returns the handle to the section

            % Process input
            tag = matlab.ui.internal.toolstrip.base.Utility.hString2Char(tag);
            if ischar(tag)
                objs = tree_deep_search_all(this, tag);
            else
                error(message('MATLAB:toolstrip:container:invalidFindAll'));
            end
        end
        
        function obj = getChildByTag(this, tag)
            % Method "getChildByTag":
            %
            %   "getChildByTag()": return all the direct children of the
            %   container or [] if none exists.
            %
            %   "getChildByTag(container, tag)": return the first object
            %   with specified tag if it exists as a direct child of the
            %   container.  If not found, errors out.
            %
            %   Example:
            %       ts1 = matlab.ui.internal.toolstrip.Toolstrip('ts1')
            %       tab1 = ts1.addTab('tab1','title1')
            %       tab1.addSection('sec1','title2')
            %       obj = tab1.getChildByTag('sec1') % returns the section

            % Process input
            if nargin == 1
                obj = this.Children;
            else
                tag = matlab.ui.internal.toolstrip.base.Utility.hString2Char(tag);
                if ischar(tag)
                    obj = tree_flat_search(this, tag);
                    if isempty(obj)
                        error(message('MATLAB:toolstrip:container:failedGetByTag'));
                    end
                else
                    error(message('MATLAB:toolstrip:container:invalidGetByTag'));                
                end
            end
        end
        
        function obj = getChildByIndex(this, idx)
            % Method "getChildByIndex":
            %
            %   "getChildByIndex()": return all the direct children of the
            %   container or [] if none exists.
            %
            %   "getChildByIndex(container, index)": return the direct
            %   child of the container with specified index.  "index" is
            %   1-based integer.
            %
            %   Example:
            %       ts1 = matlab.ui.internal.toolstrip.Toolstrip('ts1')
            %       tab1 = ts1.addTab('tab1','title1')
            %       tab1.addSection('sec1','title2')
            %       obj = tab1.getChildByIndex(1) % returns the section

            % Process input
            if nargin == 1
                obj = this.Children;
            elseif isnumeric(idx) && isscalar(idx) && isfinite(idx) && mod(idx,1)==0
                if idx>0 && idx<=length(this.Children)
                    obj = tree_flat_search(this, idx);
                else
                    error(message('MATLAB:toolstrip:container:failedGetByIndex'));
                end
            else
                error(message('MATLAB:toolstrip:container:invalidGetByIndex'));                
            end
        end
        
        %% Enable/Disable
        function disableAll(this)
            % Method "disableAll":
            %
            %   "disableAll(container)": disables all the controls
            %   hosted by the container. The container can be toolstrip,
            %   tabgroup, tab, section, panel, column and popuplist.
            %
            %   Example:
            %       % tab.disableAll()

            for ct=1:length(this.Children)
                if isa(this.Children(ct),'matlab.ui.internal.toolstrip.base.Container')
                    this.Children(ct).disableAll();
                elseif isa(this.Children(ct),'matlab.ui.internal.toolstrip.base.Control')
                    this.Children(ct).Enabled = false;
                end
            end
        end
        
        function enableAll(this)
            % Method "enableAll":
            %
            %   "enableAll(container)": enables all the controls
            %   hosted by the container. The container can be toolstrip,
            %   tabgroup, tab, section, panel, column and popuplist.
            %
            %   Example:
            %       % tab.enableAll()

            for ct=1:length(this.Children)
                if isa(this.Children(ct),'matlab.ui.internal.toolstrip.base.Container')
                    this.Children(ct).enableAll();
                elseif isa(this.Children(ct),'matlab.ui.internal.toolstrip.base.Control')
                    this.Children(ct).Enabled = true;
                end
            end
        end
        
    end

    %% common methods
    methods (Access = protected)

        function [mcos, peer] = getWidgetPropertyNames_Container(this)
            % provide MCOS and peer node name map for widget properties
            [mcos, peer] = this.getWidgetPropertyNames_Component();
        end
        
        function obj = findChildByID(this,id)
            obj = [];
            for ct=1:length(this.Children)
                if strcmp(this.Children(ct).getId(),id)
                    obj = this.Children(ct);
                    return;
                end
            end
        end            
        
    end
    
    %% hidden methods
    methods (Hidden)
        
        function render(this, channel, parent, varargin)
            % Method "render"
            %
            %   create the peer node for this container (at the orphan
            %   root) and add it to its parent (move to parent node).  If
            %   there are children, create and add those peer nodes when
            %   they are not present.
            
            % create peer node if it does not exist (orphan root)
            if ~hasPeerNode(this)
                this.PeerModelChannel = channel;
                widget_properties = this.getWidgetProperties();
                this.createPeer(widget_properties);
            end
            % create and move children peer nodes whenever necessary
            if ~isempty(this.Children)
                for ct = 1:length(this.Children)
                    component = this.Children(ct);
                    component.render(channel, this);
                end
            end
            % move this peer node (with children) to parent
            this.moveToTarget(parent,varargin{:});
        end
        
    end
    
end