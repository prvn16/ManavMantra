classdef Spinner < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Value ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_StepSize ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_ValueChanged
    % Numerical Spinner
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Spinner.Spinner">Spinner</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Value.Limits">Limits</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_StepSize.NumberFormat">NumberFormat</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_StepSize.StepSize">StepSize</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Value.Value">Value</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_ValueChanged.ValueChangedFcn">ValueChangedFcn</a>            
    %
    % Methods:
    %   N/A
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Spinner.ValueChanged">ValueChanged</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Spinner.ValueChanging">ValueChanging</a>            
    %
    % See also matlab.ui.internal.toolstrip.Slider
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.

    % -----------------------------------------------------------------------------------------
    % ATTENTION: the following settings are only valid for JavaScript rendering
    %   Properties:
    %       N/A
    %   Methods:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %   Events:
    %       N/A
    % -----------------------------------------------------------------------------------------

    % ----------------------------------------------------------------------------
    events
        % Event sent upon state changes.
        ValueChanged
        % Event sent upon state changes.
        ValueChanging
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = Spinner(varargin)
            % Constructor "Spinner": 
            %
            %   Creates a spinner.
            %
            %   Example:
            %       min = -10; max = 10; value = 5;
            %       spinner = matlab.ui.internal.toolstrip.Spinner();
            %       spinner = matlab.ui.internal.toolstrip.Spinner([min max], value);
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('Spinner');
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
            [mcos, peer] = this.getWidgetPropertyNames_Control();
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
            this.Action.addProperty('NumberFormat');
            this.Action.addProperty('MinorStepSize');
            this.Action.addProperty('MajorStepSize');
            this.Action.addCallbackFcn('ValueChanged');
        end
        
        function result = checkAction(this, control) %#ok<INUSL>
            % Abstract method defined in @control
            %
            % specify all the objects that can share action with this one.
            result = isa(control, 'matlab.ui.internal.toolstrip.Spinner');
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
            % qeValueChanged(this) mimics user changes checkbox value
            % in the UI.  "ValueChanged" event is fired with event data.
            % Note that the Value property of the MCOS object is updated.
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
        
    end
        
end
