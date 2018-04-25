classdef RadioButton < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_ButtonGroup ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Selected ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_SelectionChanged
    % Radio Button
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.RadioButton.RadioButton">RadioButton</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_ButtonGroup.ButtonGroup">ButtonGroup</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text.Text">Text</a>   
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Selected.Value">Value</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_SelectionChanged.ValueChangedFcn">ValueChangedFcn</a>            
    %
    % Methods:
    %   N/A
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.RadioButton.ValueChanged">ValueChanged</a>            
    %
    % See also matlab.ui.internal.toolstrip.ButtonGroup, matlab.ui.internal.toolstrip.Togglebutton
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    % -----------------------------------------------------------------------------------------
    % ATTENTION: the following settings are only valid for JavaScript rendering
    %   Properties:
    %       N/A
    %   Methods:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %   Events:
    %       N/A
    % -----------------------------------------------------------------------------------------

    events
        % Event triggered by selecting the radio button in the UI.
        ValueChanged
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = RadioButton(varargin)
            % Constructor "RadioButton": 
            %
            %   Create a radio button.
            %
            %   Example:
            %       group = matlab.ui.internal.toolstrip.ButtonGroup;
            %       text1 = 'Red';
            %       btn1 = matlab.ui.internal.toolstrip.RadioButton(group, text1)
            %       text2 = 'Green';
            %       btn2 = matlab.ui.internal.toolstrip.RadioButton(group, text2)
            %       text3 = 'Blue';
            %       btn3 = matlab.ui.internal.toolstrip.RadioButton(group, text3)
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('RadioButton');
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
            rules.properties.ButtonGroup = struct('type','ButtonGroup','isAction',true);
            rules.input0 = false;
            rules.input1 = {{'ButtonGroup'}};
            rules.input2 = {{'ButtonGroup','Text'}};
        end
        
        function buildWidgetPropertyMaps(this)
            % Abstract method defined in @component
            %
            % build maps between private MCOS property names and peer node
            % property names for widget properties.  The map for action
            % properties are automatically built when creating Action
            % object.
            [mcos, peer] = this.getWidgetPropertyNames_Control();
            this.WidgetPropertyMap_FromMCOSToPeer = containers.Map(mcos, peer);
            this.WidgetPropertyMap_FromPeerToMCOS = containers.Map(peer, mcos);
        end
        
        function addActionProperties(this)
            % Abstract method defined in @control
            %
            % add action properties to Action object as dynamic properties.
            this.Action.addProperty('Text');
            this.Action.addProperty('Selected');
            this.Action.addProperty('ButtonGroup');
            this.Action.addCallbackFcn('SelectionChanged');
        end
        
        function result = checkAction(this, control) %#ok<INUSL>
            % Abstract method defined in @control
            %
            % specify all the objects that can share action with this one.
            result = isa(control, 'matlab.ui.internal.toolstrip.RadioButton') ...
                || isa(control, 'matlab.ui.internal.toolstrip.ListItemWithRadioButton');
        end
        
    end
    
    %% You must put all the overloaded methods here
    methods (Access = protected)
    
        function ActionPropertySetCallback(this, ~, data)
            % only fire when the button is selected
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data.EventData);
            if strcmp(eventdata.EventData.Property,'Value')
                this.notify('ValueChanged', eventdata);   
            end
        end
        
    end
    
    %% overload render because of popup list is not a child
    methods (Hidden)    
        
        function render(this, channel, parent, varargin)
            % Method "render"
            %
            %   create the peer node
            
            % itself
            render@matlab.ui.internal.toolstrip.base.Control(this, channel, parent, varargin{:});
            % set button group id
            this.Action.setPeerProperty('buttonGroupName',this.ButtonGroup.Id);
        end
        
    end
    
    %% QE methods
    methods (Hidden)
        
        function qeValueChanged(this)
            % qeValueChanged(this) mimics user changes radio button value
            % in the UI.  "ValueChanged" event is fired with event
            % data. 
            type = 'ValueChanged';
            % generate event data
            data = struct('Property','Value','OldValue',this.Value,'NewValue',~this.Value);
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data);
            % commit in MCOS object, which also reflects new value in UI 
            this.Value = ~this.Value;
            % call SelectionChangedFcn if any
            if ~isempty(findprop(this,'ValueChangedFcn'))
                internal.Callback.execute(this.ValueChangedFcn, this, eventdata);
            end
            % fire event
            this.notify(type, eventdata);
        end
        
    end
    
end

