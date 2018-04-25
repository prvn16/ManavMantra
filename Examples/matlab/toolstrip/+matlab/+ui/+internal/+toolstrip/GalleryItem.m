classdef GalleryItem < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsFavorite ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_ItemPushed
    % Gallery Item
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryItem.GalleryItem">GalleryItem</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon.Icon">Icon</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text.Text">Text</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_ItemPushed.ItemPushedFcn">ItemPushedFcn</a>                
    %
    % Methods:
    %   N/A
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryItem.ItemPushed">ItemPushed</a>        
    %
    % See also matlab.ui.internal.toolstrip.GalleryPopup, matlab.ui.internal.toolstrip.GalleryCategory, matlab.ui.internal.toolstrip.Gallery
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    % -----------------------------------------------------------------------------------------
    % ATTENTION: the following settings are only valid for JavaScript rendering
    %   Properties:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride.DescriptionOverride">DescriptionOverride</a>        
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride.IconOverride">IconOverride</a>       
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsFavorite.IsFavorite">IsFavorite</a>        
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride.TextOverride">TextOverride</a>        
    %   Methods:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.GalleryItem.addToFavorites">addToFavorites</a>    
    %       <a href="matlab:help matlab.ui.internal.toolstrip.GalleryItem.removeFromFavorites">removeFromFavorites</a>    
    %       <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %   Events:
    %       N/A
    % -----------------------------------------------------------------------------------------

    % ----------------------------------------------------------------------------
    properties (Access = {?matlab.ui.internal.toolstrip.base.Component})
        DisplayStatePrivate = 'icon_view'
        AnimationPrivate = struct('shouldAnimate',false,'startId','','endId','')
    end
    
    % ----------------------------------------------------------------------------
    events
        % Event sent upon list item pressed in the view.
        ItemPushed
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = GalleryItem(varargin)
            % Constructor "GalleryItem": 
            %
            %   Creates a gallery item.
            %
            %   Examples:
            %
            %       import matlab.ui.internal.toolstrip.*
            %
            %       item1 = GalleryItem('Import',Icon.IMPORT_24);
            %       item2 = GalleryItem('Export',Icon.EXPORT_24);
            %       item3 = GalleryItem('Print',Icon.PRINT_24);
            %       item4 = GalleryItem('Help',Icon.HELP_24);
            %
            %       category1 = GalleryCategory('My Category 1');
            %       category1.add(item1);
            %       category1.add(item2);
            %
            %       category2 = GalleryCategory('My Category 2');
            %       category2.add(item3);
            %       category2.add(item4);
            %
            %       popup = GalleryPopup();
            %       popup.add(category1);
            %       popup.add(category2);
            %
            %       gallery = Gallery(popup);
            %
            %       item1.ItemPushedFcn = @() disp('item1 pushed');

            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('GalleryItem');
            % process custom property
            if nargin==1 && isa(varargin{1},'matlab.ui.internal.toolstrip.base.Action')
                this.setAction(varargin{1});
            else
                this.processCustomProperties(varargin{:});
            end
        end
        
    end
    
    methods (Hidden)
        
        %% render
        function render(this, channel, parent, varargin)
            % Method "render" (Overloaded):
            
            % reject invalid icon
            if isempty(this.Icon)
                error(message('MATLAB:toolstrip:control:invalidGalleryItemIcon',this.Text));
            end
            % super
            render@matlab.ui.internal.toolstrip.base.Control(this, channel, parent, varargin{:});
        end
        
        %%
        function addToFavorites(this)
            % Method "addToFavorites":
            %
            %   "addToFavorites(item)": add this item at the end of the Favorites category.
            %   Example:
            %       item = matlab.ui.internal.toolstrip.GalleryItem('new')
            %       item.addToFavorites()
            
            % update favorites category
            this.addToFavorites_private(false);
        end
        
        function removeFromFavorites(this)
            % Method "removeFromFavorites":
            %
            %   "removeFromFavorites(item)": remove this item from the Favorites category.
            %   Example:
            %       item = matlab.ui.internal.toolstrip.GalleryItem('new')
            %       item.addToFavorites()
            %       item.removeFromFavorites()
            
            % update favorites category
            this.removeFromFavorites_private(false);
        end
        
    end
    
    %% You must initialize all the abstract methods here
    methods (Access = protected)
        
        function rules = getInputArgumentRules(this) %#ok<MANU>
            % Abstract method defined in @component
            %
            % specify the rules for constructor syntax without using PV
            % pairs.  For constructor using PV pairs such as column, you
            % still need to create a dummy function though.
            rules.properties.Text = struct('type','string','isAction',true);
            rules.properties.Icon = struct('type','Icon','isAction',true);
            rules.input0 = true;
            rules.input1 = {{'Text'};{'Icon'}};
            rules.input2 = {{'Text';'Icon'}};
        end
        
        function buildWidgetPropertyMaps(this)
            % Abstract method defined in @component
            %
            % build maps between private MCOS property names and peer node
            % property names for widget properties.  The map for action
            % properties are automatically built when creating Action
            % object.
            [mcos1, peer1] = this.getWidgetPropertyNames_Control();
            [mcos2, peer2] = this.getWidgetPropertyNames_TextOverride();
            [mcos3, peer3] = this.getWidgetPropertyNames_IconOverride();
            [mcos4, peer4] = this.getWidgetPropertyNames_DescriptionOverride();
            mcos = [mcos1;mcos2;mcos3;mcos4;{'DisplayStatePrivate';'AnimationPrivate'}];
            peer = [peer1;peer2;peer3;peer4;{'displayState';'animation'}];
            this.WidgetPropertyMap_FromMCOSToPeer = containers.Map(mcos, peer);
            this.WidgetPropertyMap_FromPeerToMCOS = containers.Map(peer, mcos);
        end
        
        function addActionProperties(this)
            % Abstract method defined in @control
            %
            % add action properties to Action object as dynamic properties.
            this.Action.addProperty('Text');
            this.Action.addProperty('Icon');
            this.Action.addProperty('IsFavorite');
            this.Action.addCallbackFcn('PushPerformed');
        end
        
        function result = checkAction(this, control) %#ok<INUSL>
            % Abstract method defined in @control
            %
            % specify all the objects that can share action with this one.
            result = isa(control, 'matlab.ui.internal.toolstrip.GalleryItem');
        end
        
    end
    
    %% You must put all the overloaded methods here
    methods (Access = protected)

        function ActionPerformedCallback(this, ~, ~)
            this.notify('ItemPushed');
        end
        
        function PeerEventCallback(this,~,data)
            % client side event
            eventdata = matlab.ui.internal.toolstrip.base.Utility.processPeerEventData(data);
            if strcmp(eventdata.EventData.EventType,'FavoriteButtonPushed')
                % it does not trigger RefreshGalleryFromAPI event
                action = this.getAction();
                if action.IsFavorite
                    this.removeFromFavorites_private(true);
                else
                    this.addToFavorites_private(true);
                end
            end
        end
        
    end
    
    methods (Hidden, Access = {?matlab.ui.internal.toolstrip.Gallery, ?matlab.ui.internal.toolstrip.GalleryPopup})
        
        function action = getItemAction(this)
            action = this.getAction();
        end
        
        function addToFavorites_private(this, shouldAnimate)
            cat = this.Parent;
            if isempty(cat)
                error(message('MATLAB:toolstrip:control:failToAddToFavorites1'));
            end
            popup = cat.Parent;
            if isempty(popup)
                error(message('MATLAB:toolstrip:control:failToAddToFavorites1'));
            end
            if ~popup.UserCustomizable
                error(message('MATLAB:toolstrip:control:failToAddToFavorites2'));
            end
            action = this.getAction();
            if action.IsFavorite
                return
            else
                % create new item and add it to Favorites
                item = matlab.ui.internal.toolstrip.GalleryItem(action);
                if shouldAnimate
                    item.AnimationPrivate = struct('shouldAnimate',true,'startId',this.getId(),'endId','');
                end
                item.Tag = this.Tag;
                favorites = popup.getFavorites();
                favorites.add(item);
                action.IsFavorite = true;
            end
        end
        
        function removeFromFavorites_private(this, shouldAnimate)
            cat = this.Parent;
            if isempty(cat)
                error(message('MATLAB:toolstrip:control:failToRemoveFromFavorites1'));
            end
            action = this.getAction();
            if isa(cat,'matlab.ui.internal.toolstrip.impl.GalleryFavoriteCategory')
                % part of favorite category (only possible from UI activity)
                favorites = cat;
                popup = favorites.Popup;
                for i=1:length(popup.Children)
                    for j=1:length(popup.Children(i).Children)
                        if popup.Children(i).Children(j).getAction == action
                            endId = popup.Children(i).Children(j).getId();
                        end
                    end
                end
            else
                % part of regular category (possible from API and UI activity)
                popup = cat.Parent;
                if isempty(popup)
                    error(message('MATLAB:toolstrip:control:failToRemoveFromFavorites1'));
                elseif ~popup.UserCustomizable
                    error(message('MATLAB:toolstrip:control:failToRemoveFromFavorites2'));
                else
                    favorites = popup.getFavorites();
                end
                endId = this.getId();
            end
            if action.IsFavorite
                for ct=1:length(favorites.Children)
                    item = favorites.Children(ct);
                    if item.getAction()==action
                        if shouldAnimate
                            item.setPeerProperty('animation',struct('shouldAnimate',true,'startId','','endId',endId));                        
                        else
                            item.setPeerProperty('animation',struct('shouldAnimate',false,'startId','','endId',''));                        
                        end
                        favorites.remove(item);
                        if shouldAnimate
                            delete(item)
                        end
                        break
                    end
                end
                action.IsFavorite = false;                    
            else
                return
            end
        end
        
    end
    
    %% QE methods
    methods (Hidden)
        
        function qePushed(this)
            % qeItemPushed(this) mimics user pushes the gallery item in the
            % UI.  "ItemPushed" event is fired.
            type = 'ItemPushed';
            % call ButtonPushedFcn if any
            if ~isempty(findprop(this,'ItemPushedFcn'))
                internal.Callback.execute(this.ItemPushedFcn, this);
            end
            % fire event
            this.notify(type);
        end
        
    end
    
end

