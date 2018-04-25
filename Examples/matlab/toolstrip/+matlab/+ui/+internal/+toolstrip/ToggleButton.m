classdef ToggleButton < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_ButtonGroup ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_QuickAccessIcon ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Selected ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_SelectionChanged
    % Toggle Button
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ToggleButton.ToggleButton">ToggleButton</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_ButtonGroup.ButtonGroup">ButtonGroup</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon.Icon">Icon</a>     
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text.Text">Text</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Selected.Value">Value</a>       
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_SelectionChanged.ValueChangedFcn">ValueChangedFcn</a>            
    %
    % Methods:
    %   N/A
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ToggleButton.ValueChanged">ValueChanged</a>            
    %
    % See also matlab.ui.internal.toolstrip.ButtonGroup, matlab.ui.internal.toolstrip.Radiobutton, matlab.ui.internal.toolstrip.CheckBox
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % -----------------------------------------------------------------------------------------
    % ATTENTION: the following settings are only valid for JavaScript rendering
    %   Properties:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride.DescriptionOverride">DescriptionOverride</a>        
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride.IconOverride">IconOverride</a>        
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess.IsInQuickAccess">IsInQuickAccess</a>        
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_QuickAccessIcon.QuickAccessIcon">QuickAccessIcon</a>        
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride.TextOverride">TextOverride</a>        
    %   Methods:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess.addToQuickAccess">addToQuickAccess</a>    
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess.removeFromQuickAccess">removeFromQuickAccess</a>    
    %       <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %   Events:
    %       N/A
    % -----------------------------------------------------------------------------------------

    events
        % Event triggered by clicking the toggle button in the UI.
        ValueChanged
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% ----------- Developer API  ----------------------
        function this = ToggleButton(varargin)
            % Constructor "ToggleButton": 
            %
            %   Create a toggle button.
            %
            %   Examples:
            %       text = 'Open';
            %       icon = matlab.ui.internal.toolstrip.Icon.OPEN_24;
            %       group = matlab.ui.internal.toolstrip.ButtonGroup;
            %       btn = matlab.ui.internal.toolstrip.ToggleButton()
            %       btn = matlab.ui.internal.toolstrip.ToggleButton(icon)
            %       btn = matlab.ui.internal.toolstrip.ToggleButton(text)
            %       btn = matlab.ui.internal.toolstrip.ToggleButton(text, icon)
            %       btn = matlab.ui.internal.toolstrip.ToggleButton(text, group)
            %       btn = matlab.ui.internal.toolstrip.ToggleButton(icon, group)
            %       btn = matlab.ui.internal.toolstrip.ToggleButton(text, icon, group)
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('ToggleButton');
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
            mcos = [mcos1;mcos2;mcos3;mcos4];
            peer = [peer1;peer2;peer3;peer4];
            this.WidgetPropertyMap_FromMCOSToPeer = containers.Map(mcos, peer);
            this.WidgetPropertyMap_FromPeerToMCOS = containers.Map(peer, mcos);
        end
        
        function addActionProperties(this)
            % Abstract method defined in @control
            %
            % add action properties to Action object as dynamic properties.
            this.Action.addProperty('Text');
            this.Action.addProperty('Icon');
            this.Action.addProperty('QuickAccessIcon');
            this.Action.addProperty('IsInQuickAccess');
            this.Action.addProperty('Selected');
            this.Action.addProperty('ButtonGroup');
            this.Action.addCallbackFcn('SelectionChanged');
        end
        
        function result = checkAction(this, control)
            % Abstract method defined in @control
            %
            % specify all the objects that can share action with this one.
            result = isa(control, 'matlab.ui.internal.toolstrip.ToggleButton') ...
                || isa(control, 'matlab.ui.internal.toolstrip.impl.QABPushButton') ...
                || (isa(control, 'matlab.ui.internal.toolstrip.RadioButton') && ~isempty(this.ButtonGroup)) ...
                || (isa(control, 'matlab.ui.internal.toolstrip.CheckBox') && isempty(this.ButtonGroup)) ...
                || (isa(control, 'matlab.ui.internal.toolstrip.ListItemWithCheckBox') && isempty(this.ButtonGroup));
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
        
    end
    
    %% overload render because of popup list is not a child
    methods (Hidden)    
        
        function render(this, channel, parent, varargin)
            % Method "render"
            %
            %   create the peer node
            
            % render control itself
            render@matlab.ui.internal.toolstrip.base.Control(this, channel, parent, varargin{:});
            % set button group id
            if isempty(this.ButtonGroup)
                this.Action.setPeerProperty('buttonGroupName','');
            else
                this.Action.setPeerProperty('buttonGroupName',this.ButtonGroup.Id);
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
