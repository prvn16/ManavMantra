classdef GalleryPopup < matlab.ui.internal.toolstrip.base.Container
    % Gallery Popup
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.GalleryPopup">GalleryPopup</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.DisplayState">DisplayState</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.GalleryItemRowCount">GalleryItemRowCount</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.GalleryItemTextLineCount">GalleryItemTextLineCount</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.ShowSelection">ShowSelection</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.add">add</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.remove">remove</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.loadState">loadState</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.saveState">saveState</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.disableAll">disableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.enableAll">enableAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.find">find</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.findAll">findAll</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Container.get">get</a>
    %
    % Events:
    %   N/A
    %
    % See also matlab.ui.internal.toolstrip.GalleryCategory, matlab.ui.internal.toolstrip.GalleryItem 
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    % -----------------------------------------------------------------------------------------
    % ATTENTION: the following settings are only valid for JavaScript rendering
    %   Properties:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.UserCustomizable">UserCustomizable</a>
    %       <a href="matlab:help matlab.ui.internal.toolstrip.GalleryPopup.GalleryItemWidth">GalleryItemWidth</a>    
    %   Methods:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.GalleryItem.addToFavorites">addToFavorites</a>    
    %       <a href="matlab:help matlab.ui.internal.toolstrip.GalleryItem.removeFromFavorites">removeFromFavorites</a>    
    %       <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %   Events:
    %       N/A
    % -----------------------------------------------------------------------------------------

    % ----------------------------------------------------------------------------
    properties (Dependent, SetAccess = private)
        % Property "DisplayState": 
        %
        %   Gallery popup can be displayed in one of the two states:
        %   "icon_view" and "list_view".  Use this property to change the
        %   display state.
        %
        DisplayState
        % Property "GalleryItemRowCount": 
        %
        %   The number of rows that can be used in the gallery and gallery
        %   popup display. The default value is 1 and the valid values are
        %   1, 2 and 3.  The property is read-only.  Custom value must be
        %   provided during construction.
        %
        GalleryItemRowCount
        % Property "GalleryItemTextLineCount": 
        %
        %   The number of text lines that can be used in the gallery and
        %   gallery popup display. The default value is 2 and the valid
        %   values are 0, 1 and 2.  The property is read-only.  Custom
        %   value must be provided during construction.
        %
        GalleryItemTextLineCount
        % Property "ShowSelection": 
        %
        %   Whether or not the last selected gallery item will be displayed
        %   in the "pressed" mode.  It will also be displayed in the
        %   Gallery.
        %
        ShowSelection    
    end
    
    properties (Dependent, SetAccess = private, Hidden)
        % Property "GalleryItemWidth": 
        %
        %   The width of any gallery item displayed in the gallery and
        %   gallery popup. The default value is 80 pixels.  The property is
        %   read-only.  Custom value must be provided during construction
        %   and it is in pixels.
        %
        GalleryItemWidth
        % Property "UserCustomizable": 
        %
        %   Gallery popup by default does not provide a Favorites category.
        %   It can only be enabled during construction.  The property is
        %   read-only.
        %
        UserCustomizable
    end
    
    % ----------------------------------------------------------------------------
    properties (Access = {?matlab.ui.internal.toolstrip.base.Component})
        FavoritesPrivate = []
        GalleryItemRowCountPrivate = 1 
        GalleryItemTextLineCountPrivate = 2
        GalleryItemWidthPrivate = 80
        UserCustomizablePrivate = false
        DisplayStatePrivate = 'icon_view'
        FavCategoryIdPrivate = ''
        ShowSelectionPrivate = false
        ScrollToSelectionPrivate = true
        ShowHeaderPrivate = true
    end
    
    events (Hidden)
        RefreshGalleryJS
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = GalleryPopup(varargin)
            % Constructor "GalleryPopup": 
            %
            %   Creates a gallery popup.
            %
            %   Example #1: Gallery containing push style items
            %
            %       import matlab.ui.internal.toolstrip.* 
            %
            %       item1 = GalleryItem('Cut',Icon.CUT_24);
            %       item2 = GalleryItem('Copy',Icon.COPY_24);
            %       item3 = GalleryItem('Paste',Icon.PASTE_24);
            %
            %       category1 = GalleryCategory('My Category 1');
            %       category1.add(item1);
            %       category1.add(item2);
            %       category1.add(item3);
            %
            %       popup = GalleryPopup('GalleryItemRowCount',2);
            %       popup.add(category1);
            %
            %       gallery = Gallery(popup);
            %
            %   Example #2: Gallery containing toggle style items
            %
            %       import matlab.ui.internal.toolstrip.* 
            %
            %       item1 = ToggleGalleryItem('Cut',Icon.CUT_24);
            %       item2 = ToggleGalleryItem('Copy',Icon.COPY_24);
            %       item3 = ToggleGalleryItem('Paste',Icon.PASTE_24);
            %
            %       category1 = GalleryCategory('My Category 1');
            %       category1.add(item1);
            %       category1.add(item2);
            %       category1.add(item3);
            %
            %       popup = GalleryPopup('ShowSelection',true);
            %       popup.add(category1);
            %
            %       gallery = Gallery(popup);
            %
            %   Note: you cannot use GalleryItem and ToggleGalleryItem
            %   together in a Gallery.
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Container('GalleryPopup');
            % create favorite
            this.FavoritesPrivate = matlab.ui.internal.toolstrip.impl.GalleryFavoriteCategory(this);
            % process custom property
            this.processCustomProperties(varargin{:});
        end
        
        %% Public API: Get/Set
        % GalleryItemWidth
        function value = get.GalleryItemWidth(this)
            % GET function for ColumnWidth property.
            value = this.GalleryItemWidthPrivate;
        end
        function set.GalleryItemWidth(this, value)
            % SET function
            this.GalleryItemWidthPrivate = value;
            this.setPeerProperty('galleryItemWidth',value);
        end
        % GalleryItemRowCount
        function value = get.GalleryItemRowCount(this)
            % GET function for Popup property.
            value = this.GalleryItemRowCountPrivate;
        end
        function set.GalleryItemRowCount(this, value)
            % SET function
            this.GalleryItemRowCountPrivate = value;
            this.setPeerProperty('galleryItemRowCount',value);
        end
        % GalleryItemTextLineCount
        function value = get.GalleryItemTextLineCount(this)
            % GET function for Items property.
            value = this.GalleryItemTextLineCountPrivate;
        end
        function set.GalleryItemTextLineCount(this, value)
            % SET function
            this.GalleryItemTextLineCountPrivate = value;
            this.setPeerProperty('galleryItemTextLineCount',value);
        end
        % UserCustomizable
        function value = get.UserCustomizable(this)
            % GET function for Items property.
            value = this.UserCustomizablePrivate;
        end
        function set.UserCustomizable(this, value)
            % SET function
            this.UserCustomizablePrivate = value;
            this.setPeerProperty('userCustomizable',value);
        end
        % DisplayState
        function value = get.DisplayState(this)
            % GET function for DisplayState property.
            value = this.DisplayStatePrivate;
        end
        function set.DisplayState(this, value)
            % SET function for DisplayState property.
            this.DisplayStatePrivate = lower(value);
            this.setPeerProperty('displayState',lower(value));
        end
        % UserCustomizable
        function value = get.ShowSelection(this)
            % GET function for Items property.
            value = this.ShowSelectionPrivate;
        end
        function set.ShowSelection(this, value)
            % SET function
            this.ShowSelectionPrivate = value;
        end
        
        %% Public API: add, move and remove
        function add(this, category, varargin)
            % Method "add":
            %
            %   "add(popup, category)": add a category at the end of the popup.
            %   Example:
            %       popup = matlab.ui.internal.toolstrip.GalleryPopup
            %       category = matlab.ui.internal.toolstrip.GalleryCategory('new')
            %       popup.add(category)
            %
            %   "add(popup, category, index)": insert a category to popup at a specific location.
            %   Example:
            %       popup = matlab.ui.internal.toolstrip.GalleryPopup
            %       category1 = matlab.ui.internal.toolstrip.GalleryCategory('new')
            %       category2 = matlab.ui.internal.toolstrip.GalleryCategory('open')
            %       popup.add(category1)
            %       popup.add(category2, 1) % insert "open" before "new"
            
            if isa(category, 'matlab.ui.internal.toolstrip.GalleryCategory')
                add@matlab.ui.internal.toolstrip.base.Container(this, category, varargin{:});
            else
                error(message('MATLAB:toolstrip:container:invalidObjectAddedToParent', class(category), class(this)));
            end
            % when post rendering, force gallery to refresh for JS
            if hasPeerNode(this)
                notify(this,'RefreshGalleryJS');
            end
        end
        
        function remove(this, category)
            % Method "remove":
            %
            %   "remove(popup, category)": remove a category.
            %
            %   Example:
            %       popup = matlab.ui.internal.toolstrip.GalleryPopup
            %       category1 = matlab.ui.internal.toolstrip.GalleryCategory('new')
            %       category2 = matlab.ui.internal.toolstrip.GalleryCategory('open')
            %       popup.add(category1)
            %       popup.add(category2)
            %       popup.remove(category1) % remove "new"
            
            if isa(category, 'matlab.ui.internal.toolstrip.GalleryCategory')
                if this.isChild(category)
                    remove@matlab.ui.internal.toolstrip.base.Container(this, category);
                else
                    error(message('MATLAB:toolstrip:container:invalidChild'));
                end
            else
                error(message('MATLAB:toolstrip:container:invalidObjectRemovedFromParent', class(category), class(this)));
            end
            % when post rendering, force gallery to refresh for JS
            if hasPeerNode(this)
                notify(this,'RefreshGalleryJS');
            end
        end
        
        function state = saveState(this)
            % Method "saveState":
            %
            %   "state = saveState(popup)": save the current popup state.
            %
            %   "state" is a structure with the following fields:
            %       "FavoriteItems": a nx1 cell array of strings for favorite item Tags
            %       "Items": a mx1 cell array of strings for item tags
            %       "Categories": a kx1 cell array of strings for category tags
            %
            %   Example:
            %       popup = matlab.ui.internal.toolstrip.GalleryPopup
            %       category1 = matlab.ui.internal.toolstrip.GalleryCategory('new')
            %       category2 = matlab.ui.internal.toolstrip.GalleryCategory('open')
            %       popup.add(category1)
            %       popup.add(category2)
            %       state = popup.saveState()
            
            favorite_tags = {};
            if this.UserCustomizable
                favorites = this.getFavorites();
                for ct = 1:length(favorites.Children)
                    item = favorites.Children(ct);
                    favorite_tags = [favorite_tags; item.Tag];
                end
            end
            item_tags = {};
            category_tags = {};
            for i = 1:length(this.Children)
                cat = this.Children(i);
                for j = 1:length(cat.Children)
                    item = cat.Children(j);
                    item_tags = [item_tags; item.Tag];
                end
                category_tags = [category_tags; cat.Tag];
            end
            state = struct();
            state.FavoriteItems = favorite_tags;
            state.Items = item_tags;
            state.Categories = category_tags;
        end
        
        function loadState(this, state)
            % Method "loadState":
            %
            %   "loadState(popup, state)": load saved popup state.  must be
            %   done before rendering.
            %
            %   Example:
            %       popup = matlab.ui.internal.toolstrip.GalleryPopup
            %       category1 = matlab.ui.internal.toolstrip.GalleryCategory('new')
            %       category2 = matlab.ui.internal.toolstrip.GalleryCategory('open')
            %       popup.add(category1)
            %       popup.add(category2)
            %       popup.loadState(state) % state was previously saved by the saveState method.
            
            % Protect existing favorites from new items
            if this.UserCustomizable
                favorites = this.getFavorites();
                for ct = length(favorites.Children):-1:1
                    item = favorites.Children(ct);
                    if any(strcmp(item.Tag, state.Items))
                        item.removeFromFavorites_private(false);
                    end
                end
            end
            % add custom favorites
            for ct = 1:length(state.FavoriteItems)
                tag = state.FavoriteItems{ct};
                found = false;
                for i = 1:length(this.Children)
                    cat = this.Children(i);
                    for j = 1:length(cat.Children)
                        item = cat.Children(j);
                        found = strcmp(tag, item.Tag);
                        if found
                            item.addToFavorites_private(false);
                            break;
                        end
                    end
                    if found
                        break;
                    end
                end
            end
            % re-order category
            for ct = 1:length(state.Categories)
                tag = state.Categories{ct};
                for i = 1:length(this.Children)
                    cat = this.Children(i);
                    found = strcmp(tag, cat.Tag);
                    if found
                        this.move(cat, ct);
                        break;
                    end
                end
            end
        end
        
        %% Overload "delete" method
        function delete(this)
            % In addition, delete favorites category due to dual reference
            if isvalid(this.FavoritesPrivate)
                delete(this.FavoritesPrivate);
            end
        end
        
    end
    
    %% other methods
    methods (Access = {?matlab.ui.internal.toolstrip.GalleryItem, ?matlab.ui.internal.toolstrip.ToggleGalleryItem, ?matlab.ui.internal.toolstrip.GalleryCategory, ?matlab.ui.internal.toolstrip.Gallery, ?matlab.unittest.TestCase})
        
        function value = getFavorites(this)
            % GET function for Items property.
            value = this.FavoritesPrivate;
        end
        
        function allactions = getSortedActions(this)
            allactions1 = [];
            allactions2 = [];
            % collect actions in favorites (its order does not change programmatically)
            if this.UserCustomizable
                favorites = this.getFavorites();
                for ct = 1:length(favorites.Children)
                    allactions1 = [allactions1; favorites.Children(ct).getItemAction()]; %#ok<*AGROW>
                end
            end
            % collect actions in other categories
            for i = 1:length(this.Children)
                cat = this.Children(i);
                for j = 1:length(cat.Children)
                    item = cat.Children(j);
                    action = item.getItemAction();
                    if ~this.UserCustomizable || ~action.IsFavorite
                        allactions2 = [allactions2; action];
                    end
                end
            end
            % together
            allactions = [allactions1; allactions2];
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
            mcos = [mcos;{'GalleryItemRowCountPrivate';'GalleryItemTextLineCountPrivate';'GalleryItemWidthPrivate';'UserCustomizablePrivate';'DisplayStatePrivate';'FavCategoryIdPrivate';'ScrollToSelectionPrivate';'ShowHeaderPrivate'}];
            peer = [peer;{'galleryItemRowCount';'galleryItemTextLineCount';'galleryItemWidth';'userCustomizable';'displayState';'favCategoryId';'scrollToSelection';'showHeader'}];
            this.WidgetPropertyMap_FromMCOSToPeer = containers.Map(mcos, peer);
            this.WidgetPropertyMap_FromPeerToMCOS = containers.Map(peer, mcos);
        end
    end
    
    %% You must put all the overloaded methods here
    methods (Access = protected)
        
        function processCustomProperties(this, varargin)
            % set optional properties
            ni = nargin-1;
            if ni==0
                return
            end
            if rem(ni,2)~=0
                error(message('MATLAB:toolstrip:general:invalidPropertyValuePairs'))
            end
            PublicProps = {'DisplayState','UserCustomizable','GalleryItemRowCount','GalleryItemTextLineCount','GalleryItemWidth','ShowSelection'};
            for ct=1:2:ni
                name = matlab.ui.internal.toolstrip.base.Utility.matchProperty(varargin{ct},PublicProps);
                switch name
                    case 'DisplayState'
                        value = varargin{ct+1};
                        ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'GalleryDisplayState');
                        if ok
                            widget_properties.(name) = lower(value);
                        else
                            error(message('MATLAB:toolstrip:container:invalidGalleryDisplayState'))
                        end
                    case 'UserCustomizable'
                        value = varargin{ct+1};
                        ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'logical');
                        if ok
                            widget_properties.(name) = value;
                        else
                            error(message('MATLAB:toolstrip:container:invalidUserCustomizable'))
                        end
                    case 'GalleryItemRowCount'
                        value = varargin{ct+1};
                        ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'integer') && any(value == [1 2 3]);
                        if ok
                            widget_properties.(name) = value;
                        else
                            error(message('MATLAB:toolstrip:container:invalidGalleryItemRowCount'))
                        end
                    case 'GalleryItemTextLineCount'
                        value = varargin{ct+1};
                        ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'integer') && any(value == [0 1 2]);
                        if ok
                            widget_properties.(name) = value;
                        else
                            error(message('MATLAB:toolstrip:container:invalidGalleryItemTextLineCount'))
                        end
                    case 'GalleryItemWidth'
                        value = varargin{ct+1};
                        ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'Width');
                        if ok
                            widget_properties.(name) = value;
                        else
                            error(message('MATLAB:toolstrip:container:invalidGalleryItemWidth'))
                        end
                    case 'ShowSelection'
                        value = varargin{ct+1};
                        ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'logical');
                        if ok
                            widget_properties.(name) = value;
                        else
                            error(message('MATLAB:toolstrip:container:invalidShowSelection'))
                        end
                end
            end
            props = fieldnames(widget_properties);
            for ct=1:length(props)
                this.(props{ct}) = widget_properties.(props{ct});
            end
        end

        function PropertySetCallback(this,~,data)
            % overload the method in peer interface
            originator = data.getOriginator();
            if ~(isa(originator, 'java.util.HashMap') && strcmp(originator.get('source'),'MCOS'))
                % client side event
                if strcmp(data.getData.get('key'),'displayState')
                    % update property
                    this.DisplayStatePrivate = data.getData.get('newValue');
                end
            end
        end
        
        function valid = isModeValid(this)
            % Gallery popup do not support mixed mode.
            classes = [];
            if ~isempty(this.Children)
                for i=1:length(this.Children)
                    cat = this.Children(i);
                    if ~isempty(cat.Children)
                        for j=1:length(cat.Children)
                            item = cat.Children(j);
                            if isa(item,'matlab.ui.internal.toolstrip.GalleryItem')
                                classes = [classes; true];
                            else
                                classes = [classes; false];
                            end
                        end
                    end
                end
            end
            if isempty(classes)
                valid = true;
            else
                valid = (sum(classes)==0 && this.ShowSelection) || (sum(classes)==length(classes) && ~this.ShowSelection);
            end
        end
        
    end
        
    %% other mothods
    methods (Hidden, Access = {?matlab.ui.internal.toolstrip.GalleryCategory})

        function move(this, category, index)
            % triggered by UI
            if this.isChild(category)
                % move component in MCOS object
                tree_move(this, category.getIndex(), index);
                % move component in Peer Model (required by JS rendering)
                if hasPeerNode(this)
                    moveToTarget(category, this, index);
                end
            else
                error(message('MATLAB:toolstrip:container:invalidChild'));
            end
        end
        
    end
    
    methods (Hidden)
        
        %% render
        function render(this, channel)
            % Method "render" (Overloaded):
            
            % reject mixed usage
            if ~isModeValid(this)
                if this.ShowSelection
                    error('To use gallery in "push" mode, "ShowSelection" property must be false and all items must be GalleryItem!')
                else
                    error('To use gallery in "toggle" mode, "ShowSelection" property must be false and all items must be ToggleGalleryItem!')
                end
            end
            % set scroll to selection attribute for JS rendering
            this.ScrollToSelectionPrivate = this.ShowSelection;            
            % create favorites category
            this.FavoritesPrivate.render(channel, 'GalleryFavoriteCategory');
            % Rong: this is a temp workaround. to be removed in the future.
            this.FavoritesPrivate.dispatchEvent(struct);
            % get favorite category peer node id
            this.FavCategoryIdPrivate = this.FavoritesPrivate.getId();
            % create itself and children
            render@matlab.ui.internal.toolstrip.base.Container(this, channel, 'GalleryPopup');
        end
        
    end
    
end

