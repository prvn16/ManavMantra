classdef ListItemWithPopup < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowText ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowIcon ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowDescription ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Popup
    % List Item With Popup List
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListItemWithPopup.ListItemWithPopup">ListItemWithPopup</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon.Icon">Icon</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Popup.Popup">Popup</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowDescription.ShowDescription">ShowDescription</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text.Text">Text</a>        
    %
    % Methods:
    %   N/A
    %
    % Events:
    %   N/A
    %
    % For swing rendering, using dynamic popup list is NOT supported.
    %
    % See also matlab.ui.internal.toolstrip.PopupList, matlab.ui.internal.toolstrip.DropDownButton
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    % -----------------------------------------------------------------------------------------
    % ATTENTION: the following settings are only valid for JavaScript rendering
    %   Properties:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Popup.DynamicPopupFcn">DynamicPopupFcn</a>                
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride.DescriptionOverride">DescriptionOverride</a>        
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride.IconOverride">IconOverride</a>        
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowIcon.ShowIcon">ShowIcon</a>            
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowText.ShowText">ShowText</a>            
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride.TextOverride">TextOverride</a>        
    %   Methods:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %   Events:
    %       N/A
    % -----------------------------------------------------------------------------------------

    % ----------------------------------------------------------------------------
    events (Hidden)
        % Event triggered by clicking the button in the UI.
        DropDownPerformed
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = ListItemWithPopup(varargin)
            % Constructor "ListItem": 
            %
            %   Creates a list item used in a popup list
            %
            %   Examples:
            %       text = 'Open';
            %       icon = matlab.ui.internal.toolstrip.Icon.OPEN_16;
            %       desc = 'Open a file'
            %       item = matlab.ui.internal.toolstrip.ListItemWithPopup(text);
            %       item = matlab.ui.internal.toolstrip.ListItemWithPopup(text, icon);

            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('ListItemWithPopup');
            % process custom property
            this.processCustomProperties(varargin{:});
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
            rules.input1 = {{'Text'}};
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
            [mcos4, peer4] = this.getWidgetPropertyNames_ShowText();
            [mcos5, peer5] = this.getWidgetPropertyNames_ShowIcon();
            [mcos6, peer6] = this.getWidgetPropertyNames_ShowDescription();
            mcos = [mcos1;mcos2;mcos3;mcos4;mcos5;mcos6];
            peer = [peer1;peer2;peer3;peer4;peer5;peer6];
            this.WidgetPropertyMap_FromMCOSToPeer = containers.Map(mcos, peer);
            this.WidgetPropertyMap_FromPeerToMCOS = containers.Map(peer, mcos);
        end
        
        function addActionProperties(this)
            % Abstract method defined in @control
            %
            % add action properties to Action object as dynamic properties.
            this.Action.addProperty('Text');
            this.Action.addProperty('Icon');
            this.Action.addProperty('Popup');
            this.Action.addProperty('DynamicPopupFcn');
        end
        
        function result = checkAction(this, control) %#ok<INUSL>
            % Abstract method defined in @control
            %
            % specify all the objects that can share action with this one.
            result = isa(control, 'matlab.ui.internal.toolstrip.ListItemWithPopup') ...
                || isa(control, 'matlab.ui.internal.toolstrip.DropDownButton');
        end
        
    end
    
    %% You must put all the overloaded methods here
    methods (Access = protected)
        
        function PeerEventCallback(this,~,data)
            eventdata = matlab.ui.internal.toolstrip.base.Utility.processPeerEventData(data);
            if strcmp(eventdata.EventData.EventType,'DropDownPerformed')
                if ~isempty(this.DynamicPopupFcn)
                    % setting popup property of a rendered button
                    % automatically triggers popup rendering  
                    this.Popup = matlab.ui.internal.toolstrip.base.Utility.executeCallback(this.DynamicPopupFcn, this, eventdata);
                end
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
            
            % render popup list first
            if ~isempty(this.Popup)
                this.Popup.render(channel, 'PopupList');
            end
            % render itself
            render@matlab.ui.internal.toolstrip.base.Control(this, channel, parent, varargin{:});
            % set popup id
            if ~isempty(this.Popup)
                this.Action.setPeerProperty('popupId',this.Popup.getId());
            end
        end
        
    end
    
end
