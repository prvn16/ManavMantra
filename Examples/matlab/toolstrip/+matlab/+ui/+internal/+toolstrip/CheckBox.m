classdef CheckBox < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Selected ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_SelectionChanged
    % Check Box
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.CheckBox.CheckBox">CheckBox</a>    
    %
    % Properties:
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
    %   <a href="matlab:help matlab.ui.internal.toolstrip.CheckBox.ValueChanged">ValueChanged</a>            
    %
    % See also matlab.ui.internal.toolstrip.ToggleButton
    
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
        % Event triggered by selecting or unselecting the checkbox in the UI.
        ValueChanged
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = CheckBox(varargin)
            % Constructor "CheckBox": 
            %
            %   Create a checkbox.
            %
            %   Examples:
            %       text = 'Use default settings';
            %       value = true;
            %       cbx = matlab.ui.internal.toolstrip.CheckBox;
            %       cbx = matlab.ui.internal.toolstrip.CheckBox(text);
            %       cbx = matlab.ui.internal.toolstrip.CheckBox(text, value);

            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('CheckBox');
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
            rules.properties.Value = struct('type','logical','isAction',true);
            rules.input0 = true;
            rules.input1 = {{'Text'}};
            rules.input2 = {{'Text';'Value'}};
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
            this.Action.addCallbackFcn('SelectionChanged');
        end
        
        function result = checkAction(this, control) %#ok<INUSL>
            % Abstract method defined in @control
            %
            % specify all the objects that can share action with this one.
            result = isa(control, 'matlab.ui.internal.toolstrip.CheckBox') ...
                || isa(control, 'matlab.ui.internal.toolstrip.ListItemWithCheckBox');
        end
        
    end
    
    %% You must put all the overloaded methods here
    methods (Access = protected)
        
        function ActionPropertySetCallback(this, ~, data)
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data.EventData);
            if strcmp(eventdata.EventData.Property,'Value')
                % send out event
                this.notify('ValueChanged',eventdata);   
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

