classdef EditField < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Editable ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_PlaceholderText ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_EditableText ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_TextChanged
    % Edit Field
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.EditField.EditField">EditField</a>    
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
    %   <a href="matlab:help matlab.ui.internal.toolstrip.EditField.ValueChanged">ValueChanged</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.EditField.FocusGained">FocusGained</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.EditField.FocusLost">FocusLost</a>
    %
    % See also matlab.ui.internal.toolstrip.TextArea
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.

    % -----------------------------------------------------------------------------------------
    % ATTENTION: the following settings are only valid for JavaScript rendering
    %   Properties:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_PlaceholderText.PlaceholderText">PlaceholderText</a>            
    %   Methods:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %   Events:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.EditField.TextCancelled">TextCancelled</a>
    %       <a href="matlab:help matlab.ui.internal.toolstrip.EditField.Typing">Typing</a>
    % -----------------------------------------------------------------------------------------

    % ----------------------------------------------------------------------------
    events
        % Event sent upon text is changed.  EventData includes three fields:
        % Property, OldValue and NewValue
        ValueChanged
        % Event sent upon focus is gained.  EventData includes one field:
        % Value
        FocusGained
        % Event sent upon focus is lost.  EventData includes one field:
        % Value
        FocusLost
    end
    
    events (Hidden)
        % Event sent when text is cancelled.  EventData includes one field:
        % Value (always an empty string)
        TextCancelled
        % Event sent when typing.  EventData includes one field: Value
        Typing
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = EditField(varargin)
            % Constructor "EditField": 
            %
            %   Create a text field.
            %
            %   Example:
            %       text = '10';
            %       txtfield = matlab.ui.internal.toolstrip.EditField();
            %       txtfield = matlab.ui.internal.toolstrip.EditField(text);
           
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('TextField');
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
            rules.properties.PlaceholderText = struct('type','string','isAction',true);
            rules.input0 = true;
            rules.input1 = {{'Value'}};
            rules.input2 = {{'Value';'PlaceholderText'}};
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
            this.Action.addProperty('PlaceholderText');
            this.Action.addCallbackFcn('TextChanged');
        end
        
        function result = checkAction(this, control) %#ok<INUSL>
            % Abstract method defined in @control
            %
            % specify all the objects that can share action with this one.
            result = isa(control, 'matlab.ui.internal.toolstrip.EditField');
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
            % the UI.  "ValueChanged" event is fired with event data.  Note
            % that the Value property of the MCOS object is updated.
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
        
        function qeTyping(this, letter)
            % qeTyping(this, letter) mimics user typing a letter
            % in the UI.  "letters" are appended to existing string.
            % "Typing" event is fired with each key-strike with event data.
            % Note that since the change in UI is NOT committed, only the
            % UI is updated, the Value property of the MCOS object is NOT
            % updated.  
            type = 'Typing';
            % generate event data
            old_str = this.Value;
            new_str = [old_str letter];
            data = struct('Value', new_str);
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data);
            % update UI only
            this.Action.setPeerProperty('text', new_str);
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
        
        function qeTextCancelled(this, str)
            % qeTextCancelled(this, str) mimics escape key.
            % "TextCancelled" event is fired with event data. 
            type = 'TextCancelled';
            % generate event data
            data = struct('Value', str);
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data);
            % reset UI
            this.Action.setPeerProperty('text', this.Value);
            % fire event
            this.notify(type, eventdata);
        end
        
    end
    
end

