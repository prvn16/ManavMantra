classdef Slider < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowButton ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Value ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Steps ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Ticks ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_ValueChanged
    % Horizontal Slider
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Slider.Slider">Slider</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Ticks.Labels">Labels</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Value.Limits">Limits</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Ticks.Ticks">Ticks</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Value.Value">Value</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_ValueChanged.ValueChangedFcn">ValueChangedFcn</a>            
    %
    % Methods:
    %   N/A
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Slider.ValueChanged">ValueChanged</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Slider.ValueChanging">ValueChanging</a>            
    %
    % See also matlab.ui.internal.toolstrip.Spinner
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.

    % -----------------------------------------------------------------------------------------
    % ATTENTION: the following settings are only valid for JavaScript rendering
    %   Properties:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Steps.Steps">Steps</a>        
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowButton">ShowButton</a>        
    %   Methods:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %   Events:
    %       N/A
    % -----------------------------------------------------------------------------------------

    % ----------------------------------------------------------------------------
    events
        % Event sent upon knob is released.  EventData includes one field:
        % Value
        ValueChanged
        % Event sent upon knob is moving.  EventData includes three fields:
        % Property, OldValue and NewValue
        ValueChanging
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = Slider(varargin)
            % Constructor "Slider": 
            %
            %   Creates a slider.
            %
            %   Example:
            %       min = -10; max = 10; value = 5;
            %       slider = matlab.ui.internal.toolstrip.Slider();
            %       slider = matlab.ui.internal.toolstrip.Slider([min max], value);
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('HorizontalSlider');
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
            rules.properties.Limits = struct('type','real2','isAction',true);
            rules.properties.Value = struct('type','real','isAction',true);
            rules.input0 = true;
            rules.input2 = {{'Limits';'Value'}};
        end
        
        function buildWidgetPropertyMaps(this)
            % Abstract method defined in @component
            %
            % build maps between private MCOS property names and peer node
            % property names for widget properties.  The map for action
            % properties are automatically built when creating Action
            % object.
            [mcos1, peer1] = this.getWidgetPropertyNames_Control();
            [mcos2, peer2] = this.getWidgetPropertyNames_ShowButton();
            mcos = [mcos1;mcos2];
            peer = [peer1;peer2];
            this.WidgetPropertyMap_FromMCOSToPeer = containers.Map(mcos, peer);
            this.WidgetPropertyMap_FromPeerToMCOS = containers.Map(peer, mcos);
        end
        
        function addActionProperties(this)
            % Abstract method defined in @control
            %
            % add action properties to Action object as dynamic properties.
            this.Action.addProperty('Minimum');
            this.Action.addProperty('Maximum');
            this.Action.addProperty('Value');
            this.Action.addProperty('Steps');
            this.Action.addProperty('Ticks');
            this.Action.addProperty('Labels');
            this.Action.addCallbackFcn('ValueChanged');
        end
        
        function result = checkAction(this, control) %#ok<INUSL>
            % Abstract method defined in @control
            %
            % specify all the objects that can share action with this one.
            result = isa(control, 'matlab.ui.internal.toolstrip.Slider');
        end
        
    end
    
    %% You must put all the overloaded methods here
    methods (Access = protected)
    
        function ActionPerformedCallback(this, ~, data)
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(rmfield(data.EventData,'EventType'));
            this.notify('ValueChanged', eventdata);
        end
        
        function ActionPropertySetCallback(this, ~, data)
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data.EventData);
            if strcmp(eventdata.EventData.Property,'Value')
                this.notify('ValueChanging', eventdata);
            end
        end
        
    end
    
    %% QE methods
    methods (Hidden)
        
        function qeValueChanged(this, value)
            % qeValueChanged(this, value) mimics user moves knob to a new
            % place and then releases the knob in the UI.  "ValueChanged"
            % event is fired with event data.  Note that the Value property
            % of the MCOS object is updated.
            type = 'ValueChanged';
            % generate event data
            data = struct('Value',value);
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data);
            % commit in MCOS object, which also reflects new value in UI 
            this.Value = value;
            % call ValueChangedFcn if any
            if ~isempty(findprop(this,'ValueChangedFcn'))
                internal.Callback.execute(this.ValueChangedFcn, this, eventdata);
            end
            % fire event
            this.notify(type, eventdata);
        end
        
        function qeValueChanging(this, value)
            % qeValueChanging(this, value) mimics user continuing moving
            % knob to a new place in the UI.  "ValueChanging" event is
            % fired with event data.  Note that the Value property of the
            % MCOS object is updated.
            type = 'ValueChanging';
            % generate event data
            data = struct('Property', 'Value', 'OldValue', this.Value, 'NewValue', value);
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data);
            % commit in MCOS object, which also reflects new value in UI 
            this.Value = value;
            % fire event
            this.notify(type, eventdata);
        end
        
    end
    
end
