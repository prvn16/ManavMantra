classdef GalleryFavoriteCategory < matlab.ui.internal.toolstrip.base.Container
    % Favorites Category
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (SetAccess = private)
        Popup
    end
    
    % ----------------------------------------------------------------------------
    properties (Access = {?matlab.ui.internal.toolstrip.base.Component})
        TitlePrivate = 'FAVORITES'
        DisplayStatePrivate = 'icon_view'
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = GalleryFavoriteCategory(popup)
            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('GalleryFavoriteCategory');
            this.Popup = popup;
        end
        
        %% Public API: add and remove
        function add(this, item, varargin)
            if isa(item, 'matlab.ui.internal.toolstrip.GalleryItem') || isa(item, 'matlab.ui.internal.toolstrip.ToggleGalleryItem')
                add@matlab.ui.internal.toolstrip.base.Container(this, item, varargin{:});
            end
        end
        
        function move(this, item, index)
            if isa(item, 'matlab.ui.internal.toolstrip.GalleryItem') || isa(item, 'matlab.ui.internal.toolstrip.ToggleGalleryItem')
                if this.isChild(item)
                    % move component in MCOS object
                    tree_move(this, item.getIndex(), index);
                    % move component in Peer Model
                    moveToTarget(item, this, index);
                end
            end
        end
        
        function remove(this, item)
            if isa(item, 'matlab.ui.internal.toolstrip.GalleryItem') || isa(item, 'matlab.ui.internal.toolstrip.ToggleGalleryItem')
                if this.isChild(item)
                    remove@matlab.ui.internal.toolstrip.base.Container(this, item);
                end
            end
        end
        
    end
    
    %% You must initialize all the abstract methods here
    methods (Access = protected)

        function rules = getInputArgumentRules(this)
            % Abstract method defined in @component
            %
            % specify the rules for constructor syntax without using PV
            % pairs.  For constructor using PV pairs such as column, you
            % still need to create a dummy function though.
            rules.input0 = true;
        end
        
        function buildWidgetPropertyMaps(this)
            % Abstract method defined in @component
            %
            % build maps between private MCOS property names and peer node
            % property names for widget properties.  The map for action
            % properties are automatically built when creating Action
            % object.
            [mcos, peer] = this.getWidgetPropertyNames_Container();
            mcos = [mcos;{'TitlePrivate';'DisplayStatePrivate'}];
            peer = [peer;{'title';'displayState'}];
            this.WidgetPropertyMap_FromMCOSToPeer = containers.Map(mcos, peer);
            this.WidgetPropertyMap_FromPeerToMCOS = containers.Map(peer, mcos);
        end
        
    end
    
    %% You must put all the overloaded methods here
    methods (Access = protected)
        
        function PeerEventCallback(this,~,data)
            % client side event
            eventdata = matlab.ui.internal.toolstrip.base.Utility.processPeerEventData(data);
            if strcmp(eventdata.EventData.EventType,'ItemMoved')
                % find the item
                for ct=1:length(this.Children)
                    if strcmp(this.Children(ct).getId(),eventdata.EventData.itemId)
                        item = this.Children(ct);
                        break;
                    end
                end
                % move it (no animation)
                this.move(item, eventdata.EventData.newIndex+1);
            end
        end
        
    end
    
end
