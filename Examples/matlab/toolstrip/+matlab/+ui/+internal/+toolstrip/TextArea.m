classdef TextArea < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Editable ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_EditableText ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_TextChanged
    % Text Area
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.TextArea.TextArea">TextArea</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Editable.Editable">Editable</a>      
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_EditableText.Value">Value</a>      
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_TextChanged.ValueChangedFcn">ValueChangedFcn</a>            
    %
    % Methods:
    %   N/A
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.TextArea.ValueChanged">ValueChanged</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.TextArea.FocusGained">FocusGained</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.TextArea.FocusLost">FocusLost</a>
    %
    % See also matlab.ui.internal.toolstrip.EditField
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.

    % ----------------------------------------------------------------------------
    events
        % Event triggered by typing in the UI.
        ValueChanged
        FocusGained
        FocusLost
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = TextArea(varargin)
            % Constructor "TextArea": 
            %
            %   Create a text area.
            %
            %   Example:
            %       text = '10';
            %       textarea = matlab.ui.internal.toolstrip.TextArea()
            %       textarea = matlab.ui.internal.toolstrip.TextArea(text)
           
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('TextArea');
            % process custom property
            this.processCustomProperties(varargin{:});
            % set default editable to be true
            this.Editable = true;
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
            rules.properties.Value = struct('type','string','isAction',true);
            rules.input0 = true;
            rules.input1 = {{'Value'}};
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
            this.Action.addProperty('Editable');
            this.Action.addCallbackFcn('TextChanged');
        end
        
        function result = checkAction(this, control) %#ok<INUSL>
            % Abstract method defined in @control
            %
            % specify all the objects that can share action with this one.
            result = isa(control, 'matlab.ui.internal.toolstrip.TextArea');
        end
        
    end
    
    %% You must put all the overloaded methods here
    methods (Access = protected)
    
        function ActionPerformedCallback(this, ~, data)
            type = data.EventData.EventType;
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(rmfield(data.EventData,'EventType'));
            this.notify(type, eventdata);
        end
        
        function ActionPropertySetCallback(this, ~, data)
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data.EventData);
            if strcmp(eventdata.EventData.Property,'Value')
                this.notify('ValueChanged',eventdata);   
            end
        end
        
    end
    
    %% QE methods
    methods (Hidden)
        
        function qeValueChanged(this, str)
            % qeValueChanged(this, str) mimics user commits str in
            % the UI.  "TextChanged" event is fired with event data.  Note
            % that the Text property of the MCOS object is updated.
            type = 'ValueChanged';
            % generate event data
            data = struct('Property','Value','OldValue',this.Value,'NewValue',str);
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data);
            % commit in MCOS object, which also reflects new value in UI
            this.Value = str;
            % call ValueChangedFcn if any
            if ~isempty(findprop(this,'ValueChangedFcn'))
                internal.Callback.execute(this.ValueChangedFcn, this, eventdata);
            end
            % fire event
            this.notify(type, eventdata);
        end
        
        function qeFocusLost(this, str)
            % qeFocusLost(this, str) mimics focus lost from this
            % control.  "FocusLost" event is fired with event data.
            type = 'FocusLost';
            % generate event data
            data = struct('Value', str);
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data);
            % update UI only
            this.Action.setPeerProperty('text', str);
            % fire event
            this.notify(type, eventdata);
        end
        
        function qeFocusGained(this)
            % qeFocusGained(this) mimics focus gain at this
            % control.  "FocusGain" event is fired.
            type = 'FocusGained';
            % generate event data
            data = struct('Value', this.Value);
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data);
            % update UI only
            % to do
            % fire event
            this.notify(type, eventdata);
        end
        
    end
    
end

