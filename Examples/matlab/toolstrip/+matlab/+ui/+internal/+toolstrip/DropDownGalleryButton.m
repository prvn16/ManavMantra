classdef DropDownGalleryButton < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride ...
    % Drop Down Gallery Button
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.DropDownGalleryButton.DropDownGalleryButton">DropDownGalleryButton</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon.Icon">Icon</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.DropDownGalleryButton.MaxColumnCount">MaxColumnCount</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.DropDownGalleryButton.MinColumnCount">MinColumnCount</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.DropDownGalleryButton.Popup">Popup</a>   
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text.Text">Text</a>      
    %
    % Methods:
    %   N/A
    %
    % Events:
    %   N/A
    %
    % See also matlab.ui.internal.toolstrip.GalleryPopup, matlab.ui.internal.toolstrip.GalleryItem
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.

    % -----------------------------------------------------------------------------------------
    % ATTENTION: the following settings are only valid for JavaScript rendering
    %   Properties:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride.DescriptionOverride">DescriptionOverride</a>        
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride.IconOverride">IconOverride</a>        
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride.TextOverride">TextOverride</a>        
    %   Methods:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %   Events:
    %       N/A
    % -----------------------------------------------------------------------------------------

    % ----------------------------------------------------------------------------
    properties (Dependent, SetAccess = private)
        % Property "Popup": 
        %
        %   A GalleryPopup object that represents the gallery popup
        %   displayed under the gallery.  The property is read-only.  You
        %   must specify the GalleryPopup object in the constructor.
        %
        Popup
    end
    
    % ----------------------------------------------------------------------------
    properties (Dependent)
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
    end
    
    % ----------------------------------------------------------------------------
    properties (Access = {?matlab.ui.internal.toolstrip.base.Component})
        PopupTypePrivate = 'gallery_popup'      % used by swing rendering
        PopupPrivate = []
        PopupIdPrivate = ''
        MaxColumnCountPrivate = 10
        MinColumnCountPrivate = 4
        GalleryItemRowCountPrivate = 1          % from popup
        GalleryItemTextLineCountPrivate = 2     % from popup
        GalleryItemWidthPrivate = 80            % from popup
        ShowSelectionPrivate = false            % from popup
        ScrollToSelectionPrivate = true         % from popup
    end
    
    % ----------------------------------------------------------------------------
    events (Hidden)
        % Event triggered by clicking the button in the UI.
        DropDownPerformed
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = DropDownGalleryButton(popup, varargin)
            % Constructor "DropDownGalleryButton": 
            %
            %   Create a drop down gallery button.
            %
            %   Examples:
            %       text = 'Open';
            %       icon = matlab.ui.internal.toolstrip.Icon.OPEN_24;
            %       popup = matlab.ui.internal.toolstrip.GalleryPopup();
            %       btn = matlab.ui.internal.toolstrip.DropDownGalleryButton(popup)
            %       btn = matlab.ui.internal.toolstrip.DropDownGalleryButton(popup, text)
            %       btn = matlab.ui.internal.toolstrip.DropDownGalleryButton(popup, icon)
            %       btn = matlab.ui.internal.toolstrip.DropDownGalleryButton(popup, text,icon)

            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('DropDownButton');
            % popup
            if nargin==0
                error(message('MATLAB:toolstrip:control:invalidDropDownGalleryPopupInput'));
            end
            if isa(popup, 'matlab.ui.internal.toolstrip.GalleryPopup')
                this.PopupPrivate = popup;
            else
                error(message('MATLAB:toolstrip:control:invalidDropDownGalleryPopupInput'));
            end
            % process custom property
            this.processCustomProperties(varargin{:});
        end
        
        %% Overload "delete" method
        function delete(this)
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
            if hasPeerNode(this)
                error(message('MATLAB:toolstrip:control:noChangeMaxColumnCount'));
            else
                ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'integer') && value>0;
                if ok
                    this.MaxColumnCountPrivate = value;
                else
                    error(message('MATLAB:toolstrip:container:invalidMaxColumnCount'))
                end
            end
        end
        % MinColumnCount
        function value = get.MinColumnCount(this)
            % GET function
            value = this.MinColumnCountPrivate;
        end
        function set.MinColumnCount(this, value)
            if hasPeerNode(this)
                error(message('MATLAB:toolstrip:control:noChangeMinColumnCount'));
            else
                % SET function
                ok = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'integer') && value>0;
                if ok
                    this.MinColumnCountPrivate = value;
                else
                    error(message('MATLAB:toolstrip:container:invalidMaxColumnCount'))
                end
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
            mcos = [mcos1;mcos2;mcos3;mcos4];
            peer = [peer1;peer2;peer3;peer4];
            mcos = [mcos;{'PopupTypePrivate';'MaxColumnCountPrivate';'MinColumnCountPrivate';'GalleryItemRowCountPrivate';'GalleryItemTextLineCountPrivate';'GalleryItemWidthPrivate';'PopupIdPrivate';'ShowSelectionPrivate';'ScrollToSelectionPrivate'}];
            peer = [peer;{'popupType';'maxColumnCount';'minColumnCount';'galleryItemRowCount';'galleryItemTextLineCount';'galleryItemWidth';'popupId';'showSelection';'scrollToSelection'}];
            this.WidgetPropertyMap_FromMCOSToPeer = containers.Map(mcos, peer);
            this.WidgetPropertyMap_FromPeerToMCOS = containers.Map(peer, mcos);
        end
        
        function addActionProperties(this)
            % Abstract method defined in @control
            %
            % add action properties to Action object as dynamic properties.
            this.Action.addProperty('Text');
            this.Action.addProperty('Icon');
        end
        
        function result = checkAction(this, control) %#ok<INUSL>
            % Abstract method defined in @control
            %
            % specify all the objects that can share action with this one.
            result = isa(control, 'matlab.ui.internal.toolstrip.DropDownGalleryButton');
        end
        
    end
    
    %% You must put all the overloaded methods here
    methods (Access = protected)
        
        function processCustomProperties(this, varargin)
            % super
            processCustomProperties@matlab.ui.internal.toolstrip.base.Component(this,varargin{:});
            % set carry over properties from popup
            this.GalleryItemRowCountPrivate = this.Popup.GalleryItemRowCount;
            this.GalleryItemTextLineCountPrivate = this.Popup.GalleryItemTextLineCount;
            this.GalleryItemWidthPrivate = this.Popup.GalleryItemWidth;
            this.ShowSelectionPrivate = this.Popup.ShowSelection;
            this.ScrollToSelectionPrivate = this.Popup.ShowSelection;
        end

        function PeerEventCallback(this,~,data)
            eventdata = matlab.ui.internal.toolstrip.base.Utility.processPeerEventData(data);
            if strcmp(eventdata.EventData.EventType,'DropDownPerformed')
                if ~isempty(this.Popup) && isvalid(this.Popup)
                    this.dispatchEvent(struct('eventType','showPopup','popupId',this.Popup.getId()));
					% hidden QE event
					this.notify('DropDownPerformed');
                end
            end
        end
        
    end
    
    %% overload render because of popup list is not a child
    methods (Hidden)    
        
        function render(this, channel, parent, varargin)
            % Method "render"
            %
            %   create the peer node
            
            % create gallery popup
            this.Popup.render(channel);
            % ensure gallery popup is created before gallry on client side
            this.Popup.dispatchEvent(struct);
            % get popup peer node id
            this.PopupIdPrivate = this.Popup.getId();
            % render itself
            render@matlab.ui.internal.toolstrip.base.Control(this, channel, parent, varargin{:});
        end
        
    end
    
    %% QE methods
    methods (Hidden)
        
        function qeDropDownGalleryPushed(this)
            % qeDropDownGalleryPushed(this) mimics user pushes the drop
            % down gallery button in the UI without displaying the popup
            if ~isempty(this.Popup) && isvalid(this.Popup)
				this.notify('DropDownPerformed');
            end
        end
        
    end
    
end
