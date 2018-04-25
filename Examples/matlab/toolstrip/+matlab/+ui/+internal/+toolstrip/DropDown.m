classdef DropDown < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Editable ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Items ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_PlaceholderText ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_ItemSelected
    % Drop Down (Combo Box)
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.DropDown.DropDown">DropDown</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Editable.Editable">Editable</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Items.Items">Items</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.DropDown.SelectedIndex">SelectedIndex</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.DropDown.Value">Value</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_ItemSelected.ValueChangedFcn">ValueChangedFcn</a>            
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Items.addItem">addItem</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Items.removeItem">removeItem</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Items.replaceAllItems">replaceAllItems</a>
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.DropDown.ValueChanged">ValueChanged</a>            
    %
    % See also matlab.ui.internal.toolstrip.ListBox
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    % -----------------------------------------------------------------------------------------
    % ATTENTION: the following settings are only valid for JavaScript rendering
    %   Properties:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_PlaceholderText.PlaceholderText">PlaceholderText</a>            
    %   Methods:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %   Events:
    %       N/A
    % -----------------------------------------------------------------------------------------

    events
        % Event triggered by selecting or hitting enter key (editable) in the UI.
        % EventData includes three fields: Property, OldValue and NewValue
        ValueChanged
    end
    
    properties (Dependent, Access = public)
        % Property "SelectedIndex":
        %
        %   The index of value.  If the value is not part of the items, it
        %   returns -1.
        %   It is an integer and the default value is -1.
        %   It is writable.
        %
        %   Example:
        %       combo = matlab.ui.internal.toolstrip.CombokBox({'item1','item2','item3'})
        %       combo.SelectedIndex     % returns -1
        %       combo.SelectedIndex = 2 % select 'item2'
        SelectedIndex
        % Property "Value":
        %
        %   Value represents the selected state.  If Editable is false, the
        %   selected state is one of the states in the Items.  If Editable
        %   is true, the selected state can be any string. 
        %
        %   It is a string and the default value is ''.  It is writable.
        %   When Editable is true, Value should not be programmatically set
        %   to a string that is not a state in the Items property.
        %
        %   Example:
        %       combo = matlab.ui.internal.toolstrip.CombokBox({'item1','item2','item3'})
        %       combo.Value % returns ''
        %       combo.Value = 'item2 % select 'item2'
        %       combo.Editable = true;
        %       combo.Value = 'abc'; % set to a value not in the list
        Value
    end
    
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = DropDown(varargin)
            % Constructor "DropDown": 
            %
            %   Create a drop down (combobox).
            %
            %   Example:
            %       values = {'One';'Two';'Three'};
            %       items = {'One' 'Label1';'Two' 'Label2';'Three' 'Label3'};
            %       cmb = matlab.ui.internal.toolstrip.DropDown;
            %       cmb = matlab.ui.internal.toolstrip.DropDown(values);
            %       cmb = matlab.ui.internal.toolstrip.DropDown(items);
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('ComboBox');
            % process custom property
            this.processCustomProperties(varargin{:});
        end
        
        %% Public API: Get/Set
        % Value
        function value = get.Value(this)
            % GET function for Value property.
            value = this.Action.SelectedItem;
        end
        function set.Value(this, value)
            % SET function for Value property.
            this.Action.SelectedItem = value;
        end
        % SelectedIndex
        function value = get.SelectedIndex(this)
            % GET function for SelectedIndex property.
            if isempty(this.Value)
                value = -1;
            else
                value = find(strcmp(this.Value, this.Items(:,1)));
                if isempty(value)
                    value = -1;
                end
            end
        end
        function set.SelectedIndex(this, value)
            % SET function for SelectedIndex property.
            if ~(matlab.ui.internal.toolstrip.base.Utility.validate(value, 'integer') && ((value == -1) || (value > 0 && value <= size(this.Items,1))))
                error(message('MATLAB:toolstrip:control:invalidSelectedIndex'))
            end
            if value == -1
                this.Value = '';
            else
                this.Value = this.Items{value,1};
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
            rules.properties.Items = struct('type','Items','isAction',true);            
            rules.input0 = true;
            rules.input1 = {{'Items'}};
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
            this.Action.addProperty('Items');
            this.Action.addProperty('Editable');
            this.Action.addProperty('PlaceholderText');
            this.Action.addProperty('SelectedItem');
            this.Action.addCallbackFcn('ItemSelected');
        end
        
        function result = checkAction(this, control) %#ok<INUSL>
            % Abstract method defined in @control
            %
            % specify all the objects that can share action with this one.
            result = isa(control, 'matlab.ui.internal.toolstrip.DropDown');
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
    
    %% QE methods
    methods (Hidden)
        
        function qeValueChanged(this, item)
            % qeItemSelected(this, item) mimics user selects or type a new
            % item in the UI.  "ValueChanged" event is fired with event
            % data.  Note that the Value property of the MCOS object
            % is updated.
            type = 'ValueChanged';
            % generate event data
            data = struct('Property','Value','OldValue',this.Value,'NewValue',item);
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data);
            % commit in MCOS object, which also reflects new value in UI 
            this.Value = item;
            % call ItemSelectedFcn if any
            if ~isempty(findprop(this,'ValueChangedFcn'))
                internal.Callback.execute(this.ValueChangedFcn, this, eventdata);
            end
            % fire event
            this.notify(type, eventdata);
        end
        
%         function qeTextChanged(this, str)
%             % qeTextChanged(this, str) mimics user commits str in
%             % the UI.  "TextChanged" event is fired with event data.  Note
%             % that the Text property of the MCOS object is updated.
%             type = 'TextChanged';
%             % generate event data
%             data = struct('Property','Text','OldValue',this.Text,'NewValue',str);
%             eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data);
%             % commit in MCOS object, which also reflects new value in UI 
%             this.Text = str;
%             % call TextChangedFcn if any
%             if ~isempty(findprop(this,'TextChangedFcn'))
%                 internal.Callback.execute(this.TextChangedFcn, this, eventdata);
%             end
%             % fire event
%             this.notify(type, eventdata);
%         end
%         
%         function qeTyping(this, letter)
%             % qeTyping(this, letter) mimics user typing a letter
%             % in the UI.  "letters" are appended to existing string.
%             % "Typing" event is fired with each key-strike with event data.
%             % Note that since the change in UI is NOT committed, only the
%             % UI is updated, the Text property of the MCOS object is NOT
%             % updated.  
%             type = 'Typing';
%             % generate event data
%             old_str = this.Text;
%             new_str = [old_str letter];
%             data = struct('Text', new_str);
%             eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data);
%             % update UI only
%             this.setPeerProperty('text', new_str);
%             % fire event
%             this.notify(type, eventdata);
%         end
%         
%         function qeFocusLost(this, str)
%             % qeFocusLost(this, str) mimics focus lost from this
%             % control.  "FocusLost" event is fired with event data.
%             type = 'FocusLost';
%             % generate event data
%             data = struct('Text', str);
%             eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data);
%             % update UI only
%             this.setPeerProperty('text', str);
%             % fire event
%             this.notify(type, eventdata);
%         end
%         
%         function qeFocusGained(this)
%             % qeFocusGained(this) mimics focus gain at this
%             % control.  "FocusGain" event is fired.
%             type = 'FocusGained';
%             % update UI only
%             % to do
%             % fire event
%             this.notify(type);
%         end
%         
%         function qeTextCancelled(this, str)
%             % qeTextCancelled(this, str) mimics escape key.
%             % "TextCancelled" event is fired with event data. 
%             type = 'TextCancelled';
%             % generate event data
%             data = struct('Text', str);
%             eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data);
%             % reset UI
%             this.setPeerProperty('text', this.Text);
%             % fire event
%             this.notify(type, eventdata);
%         end
        
    end
    
end