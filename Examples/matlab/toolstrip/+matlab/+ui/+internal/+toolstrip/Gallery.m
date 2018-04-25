classdef Gallery < matlab.ui.internal.toolstrip.base.Control
    % Collective Gallery
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Gallery.Gallery">Gallery</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Gallery.MaxColumnCount">MaxColumnCount</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Gallery.MinColumnCount">MinColumnCount</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Gallery.Popup">Popup</a>   
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Gallery.TextOverlay">TextOverlay</a>   
    %
    % Methods:
    %   N/A
    %
    % Events:
    %   N/A
    %
    % See also matlab.ui.internal.toolstrip.GalleryPopup
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, SetAccess = private)
        % Property "MaxColumnCount": 
        %
        %   The maximum number of columns that can be used in the gallery
        %   display. The default value is 10 columns.  The property is
        %   read-only.  Custom value must be provided during construction.
        %
        MaxColumnCount
        % Property "MinColumnCount": 
        %
        %   The minimum number of columns that can be used in the gallery
        %   display.  The default value is 1 column.  The property is
        %   read-only.  Custom value must be provided during construction.
        %
        MinColumnCount
        % Property "Popup": 
        %
        %   A GalleryPopup object that represents the gallery popup
        %   displayed under the gallery.  The property is read-only.  You
        %   must specify the GalleryPopup object in the constructor.
        %
        Popup
    end
    
    properties (Dependent)    
        % Property "TextOverlay": 
        %
        %   TextOverlay takes a string.  If specified, the string will be
        %   displayed in the center of the gallery.  Use '' to remove overlay text.
        %   The default value is ''.  It is writable.
        TextOverlay
    end
    
    % ----------------------------------------------------------------------------
    properties (Access = {?matlab.ui.internal.toolstrip.base.Component})
        PopupPrivate = []
        MaxColumnCountPrivate = 10
        MinColumnCountPrivate = 1
        TextOverlayPrivate = ''
        GalleryItemRowCountPrivate = 1
        GalleryItemTextLineCountPrivate = 2
        GalleryItemWidthPrivate = 80
        CurrentColumnCountPrivate = 10
        GalleryPopupIdPrivate = ''
        ShouldRefreshPrivate = true
        ShowSelectionPrivate = false
        ScrollToSelectionPrivate = true
        DisplayStatePrivate = 'normal'
    end
    
    properties (Access = private)
        Timer
        TimerListener
    end

    % ----------------------------------------------------------------------------
    % Public methods
    methods

        %% Constructor
        function this = Gallery(varargin)
            % Constructor "Gallery":
            %
            %   Creates a gallery from a pre-defined GalleryPopup.
            %
            %   Examples:
            %
            %       item1 = matlab.ui.internal.toolstrip.GalleryItem('Item1');
            %       item2 = matlab.ui.internal.toolstrip.GalleryItem('Item2');
            %       item3 = matlab.ui.internal.toolstrip.GalleryItem('Item3');
            %       item4 = matlab.ui.internal.toolstrip.GalleryItem('Item4');
            %
            %       category1 = matlab.ui.internal.toolstrip.GalleryCategory('My Category 1');
            %       category1.add(item1);
            %       category1.add(item2);
            %
            %       category2 = matlab.ui.internal.toolstrip.GalleryCategory('My Category 2');
            %       category2.add(item3);
            %       category2.add(item4);
            %
            %       popup = matlab.ui.internal.toolstrip.GalleryPopup;
            %       popup.add(category1);
            %       popup.add(category2);
            %
            %       gallery = matlab.ui.internal.toolstrip.Gallery(popup, 'MaxColumnCount', 12, 'MinColumnCount', 3);
            %
            %   Note that: after a gallery object is constructed, you
            %   cannot replace with another gallery popup.

            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('Gallery');
            % process custom property
            this.processCustomProperties(varargin{:});
            % create 100ms timer for throttling gallery refreshing requests post-rendering 
            this.Timer = timer('StartDelay',0.1,'TimerFcn',@(x,y) refreshGalleryJS(this));
            this.Timer.ObjectVisibility = 'off';
        end

        %% Overload "delete" method
        function delete(this)
            % Delete timer listener
            if ~isempty(this.TimerListener)
                delete(this.TimerListener)
            end
            % Delete timer
            if ~isempty(this.Timer) && isvalid(this.Timer)
                stop(this.Timer);
                delete(this.Timer);
            end
            % Tell the JS Gallery to not trigger refresh since Gallery,
            % GalleryPopup etc. are being destroyed
            this.ShouldRefreshPrivate = false;
            this.setPeerProperty('shouldRefresh', false);
            % Ensure a sync of the 'shouldRefresh' property happens before
            % destruction goes further
            this.dispatchEvent(struct);

            % Manually delete GalleryPopup
            if ~isempty(this.Popup) && isvalid(this.Popup)
                delete(this.Popup);
            end
        end

        %% Public API: Get/Set
        % Popup
        function value = get.Popup(this)
            % GET function for Popup property.
            value = this.PopupPrivate;
        end
        function set.Popup(this, value)
            % SET function
            this.PopupPrivate = value;
        end
        % MaxColumnCount
        function value = get.MaxColumnCount(this)
            % GET function for MaxColumnCount property.
            value = this.MaxColumnCountPrivate;
        end
        function set.MaxColumnCount(this, value)
            % SET function
            this.MaxColumnCountPrivate = value;
        end
        % MinColumnCount
        function value = get.MinColumnCount(this)
            % GET function
            value = this.MinColumnCountPrivate;
        end
        function set.MinColumnCount(this, value)
            % SET function
            this.MinColumnCountPrivate = value;
        end
        % TextOverlay
        function value = get.TextOverlay(this)
            % GET function
            value = this.TextOverlayPrivate;
        end
        function set.TextOverlay(this, value)
            % SET function
            value = matlab.ui.internal.toolstrip.base.Utility.hString2Char(value);
            if isempty(value)
                value = '';
            elseif ~ischar(value)
                error(message('MATLAB:toolstrip:container:invalidTextOverlay'))
            end
            this.TextOverlayPrivate = value;
            this.setPeerProperty('textOverlay',value);
        end
        
        function setBusy(this, value)
            % Set to true to disable Gallery and display a busy curser.
            % Commonly used when gallery popup needs to be refreshed.
            %
            % Example:
            %   setBusy(this, true)
            %   update gallery category and items by adding or removing
            %   setBusy(this, false)
            if value
                this.DisplayStatePrivate = 'busy';
                this.setPeerProperty('displayState','busy');
            else
                this.DisplayStatePrivate = 'normal';
                this.setPeerProperty('displayState','normal');
            end
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
            [mcos, peer] = this.getWidgetPropertyNames_Control();
            mcos = [mcos;{'MaxColumnCountPrivate';'CurrentColumnCountPrivate';'MinColumnCountPrivate';'TextOverlayPrivate';'GalleryItemRowCountPrivate';'GalleryItemTextLineCountPrivate';'GalleryItemWidthPrivate';'GalleryPopupIdPrivate';'ShouldRefreshPrivate';'ShowSelectionPrivate';'DisplayStatePrivate';'ScrollToSelectionPrivate'}];
            peer = [peer;{'maxColumnCount';'currentColumnCount';'minColumnCount';'textOverlay';'galleryItemRowCount';'galleryItemTextLineCount';'galleryItemWidth';'galleryPopupId';'shouldRefresh';'showSelection';'displayState';'scrollToSelection'}];
            this.WidgetPropertyMap_FromMCOSToPeer = containers.Map(mcos, peer);
            this.WidgetPropertyMap_FromPeerToMCOS = containers.Map(peer, mcos);
        end

    end

    %% You must put all the overloaded methods here
    methods (Access = protected)

        function processCustomProperties(this, varargin)
            %  popup
            if nargin==1
                error(message('MATLAB:toolstrip:container:invalidGalleryPopupInput'));
            end
            popup = varargin{1};
            if isa(popup, 'matlab.ui.internal.toolstrip.GalleryPopup')
                this.PopupPrivate = popup;
            else
                error(message('MATLAB:toolstrip:container:invalidGalleryPopupInput'));
            end
            % set optional properties
            ni = nargin-2;
            if ni>0
                if rem(ni,2)~=0
                    error(message('MATLAB:toolstrip:general:invalidPropertyValuePairs'))
                end
                PublicProps = {'MaxColumnCount','MinColumnCount'};
                for ct=1:2:ni
                    name = matlab.ui.internal.toolstrip.base.Utility.matchProperty(varargin{ct+1},PublicProps);
                    switch name
                        case 'MaxColumnCount'
                            value = varargin{ct+2};
                            ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'integer') && value>0;
                            if ok
                                widget_properties.(name) = value;
                                widget_properties.CurrentColumnCountPrivate = value;
                            else
                                error(message('MATLAB:toolstrip:container:invalidMaxColumnCount'))
                            end
                        case 'MinColumnCount'
                            value = varargin{ct+2};
                            ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'integer') && value>0;
                            if ok
                                widget_properties.(name) = value;
                            else
                                error(message('MATLAB:toolstrip:container:invalidMinColumnCount'))
                            end
                    end
                end
            end
            % set carry over properties
            widget_properties.GalleryItemRowCountPrivate = popup.GalleryItemRowCount;
            widget_properties.GalleryItemTextLineCountPrivate = popup.GalleryItemTextLineCount;
            widget_properties.GalleryItemWidthPrivate = popup.GalleryItemWidth;
            widget_properties.ShowSelectionPrivate = popup.ShowSelection;
            widget_properties.ScrollToSelectionPrivate = popup.ShowSelection;
            % set properties
            props = fieldnames(widget_properties);
            for ct=1:length(props)
                this.(props{ct}) = widget_properties.(props{ct});
            end
        end

        function addActionProperties(this) %#ok<MANU>
            % Abstract method defined in @control
            %
            % add action properties to Action object as dynamic properties.
            % null op here.
        end
        
        function result = checkAction(this, control) %#ok<INUSL>
            % Abstract method defined in @control
            %
            % specify all the objects that can share action with this one.
            result = isa(control, 'matlab.ui.internal.toolstrip.Gallery');
        end
        
        function refreshGalleryJS(this)
            % force synchronization on the client side (JS only)
            this.dispatchEvent(struct('eventType','refreshGallery','galleryId',this.getId()));
            this.getAction.dispatchEvent(struct('eventType','refreshGallery','galleryId',this.getId()));
        end
        
        function timerCallback(this)
            % throttle gallery refresh events sent from popup by resetting timer
            if ~isempty(this.Timer) && isvalid(this.Timer)
                stop(this.Timer);
                start(this.Timer);
            end
        end
        
    end

    %% Other methods
    methods (Hidden)

        %% render
        function render(this, channel, parent, varargin)
            % Method "render" (Overloaded):

            % create gallery popup
            this.Popup.render(channel);
            % ensure gallery popup is created before gallry on client side
            this.Popup.dispatchEvent(struct);
            % get popup peer node id
            this.GalleryPopupIdPrivate = this.Popup.getId();
            % create itself
            render@matlab.ui.internal.toolstrip.base.Control(this, channel, parent, varargin{:});
            % force synchronization on the client side
            refreshGalleryJS(this);
            % add timer listener for post-rendering gallery refreshing
            this.TimerListener = addlistener(this.Popup,'RefreshGalleryJS',@(x,y) timerCallback(this));
        end

    end

end
