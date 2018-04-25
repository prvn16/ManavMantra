classdef ToggleGalleryItem < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_ButtonGroup ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsFavorite ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Selected ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_SelectionChanged ...
    % Toggle Gallery Item
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ToggleGalleryItem.ToggleGalleryItem">ToggleGalleryItem</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_ButtonGroup.ButtonGroup">ButtonGroup</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon.Icon">Icon</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text.Text">Text</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Selected.Value">Value</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_ValueChanged.ValueChanged">ValueChanged</a>                
    %
    % Methods:
    %   N/A
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ToggleGalleryItem.ValueChanged">ValueChanged</a>        
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
    %       <a href="matlab:help matlab.ui.internal.toolstrip.ToggleGalleryItem.addToFavorites">addToFavorites</a>    
    %       <a href="matlab:help matlab.ui.internal.toolstrip.ToggleGalleryItem.removeFromFavorites">removeFromFavorites</a>    
    %       <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %   Events:
    %       N/A
    % -----------------------------------------------------------------------------------------

    % ----------------------------------------------------------------------------
    properties (Access = {?matlab.ui.internal.toolstrip.base.Component})
        DisplayStatePrivate = 'icon_view'
        AnimationPrivate = struct('shouldAnimate',false,'startId','','endId','');
    end
    
    % ----------------------------------------------------------------------------
    events
        % Event triggered by clicking the toggle button in the UI.
        ValueChanged
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = ToggleGalleryItem(varargin)
            % Constructor "GalleryItemToggle": 
            %
            %   Creates a toggle gallery item.
            %
            %   Examples:
            %
            %       import matlab.ui.internal.toolstrip.*
            %
            %       item1 = ToggleGalleryItem('New',Icon.NEW_24);
            %       item2 = ToggleGalleryItem('Open',Icon.OPEN_24);
            %       item3 = ToggleGalleryItem('Save',Icon.SAVE_24);
            %
            %       group = ButtonGroup();
            %       item4 = ToggleGalleryItem('Cut',Icon.CUT_24,group);
            %       item5 = ToggleGalleryItem('Copy',Icon.COPY_24,group);
            %       item6 = ToggleGalleryItem('Paste',Icon.PASTE_24,group);
            %
            %       category1 = GalleryCategory('My Category 1');
            %       category1.add(item1);
            %       category1.add(item2);
            %       category1.add(item3);
            %
            %       category2 = GalleryCategory('My Category 2');
            %       category2.add(item4);
            %       category2.add(item5);
            %       category2.add(item6);
            %
            %       popup = matlab.ui.internal.toolstrip.GalleryPopup('ShowSelection',true);
            %       popup.add(category1);
            %       popup.add(category2);
            %
            %       gallery = matlab.ui.internal.toolstrip.Gallery(popup);
            %
            %       item1.ValueChangedFcn = @() disp('item1 value changed');

            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('ToggleGalleryItem');
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
            % set button group id
            if isempty(this.ButtonGroup)
                this.Action.setPeerProperty('buttonGroupName','');
            else
                this.Action.setPeerProperty('buttonGroupName',this.ButtonGroup.Id);
            end
        end
        
        %%
        function addToFavorites(this)
            % Method "addToFavorites":
            %
            %   "addToFavorites(item)": add this item at the end of the Favorites category.
            %   Example:
            %       item = matlab.ui.internal.toolstrip.ToggleGalleryItem('new')
            %       item.addToFavorites()
            
            % update favorites category
            this.addToFavorites_private(false);
        end
        
        function removeFromFavorites(this)
            % Method "removeFromFavorites":
            %
            %   "removeFromFavorites(item)": remove this item from the Favorites category.
            %   Example:
            %       item = matlab.ui.internal.toolstrip.ToggleGalleryItem('new')
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
            rules.properties.ButtonGroup = struct('type','ButtonGroup','isAction',true);
            rules.input0 = true;
            rules.input1 = {{'Text'};{'Icon'};{'ButtonGroup'}};
            rules.input2 = {{'Text';'Icon'};{'Text';'ButtonGroup'};{'Icon';'ButtonGroup'}};
            rules.input3 = {{'Text';'Icon';'ButtonGroup'}};
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
            this.Action.addProperty('ButtonGroup');
            this.Action.addProperty('Selected');            
            this.Action.addCallbackFcn('SelectionChanged');
        end
        
        function result = checkAction(this, control) %#ok<INUSL>
            % Abstract method defined in @control
            %
            % specify all the objects that can share action with this one.
            result = isa(control, 'matlab.ui.internal.toolstrip.ToggleGalleryItem');
        end
        
    end
    
    %% You must put all the overloaded methods here
    methods (Access = protected)

        function ActionPropertySetCallback(this, ~, data)
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data.EventData);
            if strcmp(eventdata.EventData.Property,'Value')
                this.notify('ValueChanged',eventdata);   
            end
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
                item = matlab.ui.internal.toolstrip.ToggleGalleryItem(action);
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
        
        function qeValueChanged(this)
            % qeValueChanged(this) mimics user changes checkbox value
            % in the UI.  "ValueChanged" event is fired with event
            % data. 
            type = 'ValueChanged';
            % generate event data
            data = struct('Property','Value','OldValue',this.Value,'NewValue',~this.Value);
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data);
            % commit in MCOS object, which also reflects new value in UI 
            this.Value = ~this.Value;
            % call ValueChangedFcn if any
            if ~isempty(findprop(this,'ValueChangedFcn'))
                internal.Callback.execute(this.ValueChangedFcn, this, eventdata);
            end
            % fire event
            this.notify(type, eventdata);
        end
        
    end
    
end

