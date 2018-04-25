classdef ListBox < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Items ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_ItemSelected
    % List Box
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListBox.ListBox">ListBox</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Items.Items">Items</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListBox.MultiSelect">MultiSelect</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListBox.SelectedIndex">SelectedIndex</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListBox.Value">Value</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_ItemSelected.ValueChangedFcn">ValueChangedFcn</a>            
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Items.addItem">addItem</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Items.removeItem">removeItem</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Items.replaceAllItems">replaceAllItems</a>
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListBox.ValueChanged">ValueChanged</a>            
    %
    % See also matlab.ui.internal.toolstrip.DropDown
    
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
        % Event triggered by selecting in the UI.
        ValueChanged
    end
    
    properties (Dependent, Access = public)
        % Property "SelectedIndex":
        %
        %   The indices of the selected items
        %   It is an integer array and the default value is -1 (unselected).
        %   It is writable.
        %
        %   Example:
        %       listbox = matlab.ui.internal.toolstrip.ListBox({'item1','item2','item3'})
        %       listbox.SelectedIndex   % returns -1
        %       listbox.SelectedIndex = [2 3] % select 'item2' and 'item3'
        SelectedIndex
        % Property "Value":
        %
        %   Store the selected values
        %   It is a cell array of strings and the default value is {}.
        %   It is writable.
        %
        %   Example:
        %       combo = matlab.ui.internal.toolstrip.ListBox({'item1','item2','item3'}, true)
        %       combo.Value     % returns {}
        %       combo.Value = {'item2 'item3'} % select 'item2' and 'item3'
        Value
    end
    
    properties (Dependent, SetAccess = {?matlab.ui.internal.toolstrip.base.Component})
        % Property "MultiSelect":
        %
        %   ListBox has two selection mode: single or multiple.  Default
        %   value is false.  To enable multiple selection, specify it in
        %   the constructor.  This property is read-only.
        %
        %   Example:
        %       combo = matlab.ui.internal.toolstrip.ListBox({'value1' 'label1';'value2' 'label2';'value3' 'label3'}, true)
        MultiSelect
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% ----------- Developer API  ----------------------
        %% Constructor
        function this = ListBox(varargin)
            % Constructor "ListBox": 
            %
            %   Create a list box.
            %
            %   Example:
            %       values = {'One';'Two';'Three'};
            %       items = {'One' 'Label1';'Two' 'Label2';'Three' 'Label3'};
            %       multiple_selection = true;
            %       cmb = matlab.ui.internal.toolstrip.ListBox;
            %       cmb = matlab.ui.internal.toolstrip.ListBox(values);
            %       cmb = matlab.ui.internal.toolstrip.ListBox(items);
            %       cmb = matlab.ui.internal.toolstrip.ListBox(values, multiple_selection);
            %       cmb = matlab.ui.internal.toolstrip.ListBox(items, multiple_selection);
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('List');
            % process custom property
            this.processCustomProperties(varargin{:});
        end
        
        %% Public API: Get/Set
        % Value
        function value = get.Value(this)
            % GET function for Value property.
            value = this.Action.SelectedItems;
        end
        function set.Value(this, value)
            % SET function for Value property.
            len = length(value);
            for ct=1:len
                if ~any(strcmp(value(ct), this.Items(:,1)))
                    error(message('MATLAB:toolstrip:control:invalidSelectedItem'));
                end
            end
            this.Action.SelectedItems = value;
        end
        % SelectedIndex
        function value = get.SelectedIndex(this)
            % GET function for SelectedIndex property.
            if isempty(this.Value)
                value = -1;
            else
                len = length(this.Value);
                value = zeros(len,1);
                for ct=1:len
                    value(ct) = find(strcmp(this.Value(ct), this.Items(:,1)));
                end
            end
        end
        function set.SelectedIndex(this, values)
            % SET function for SelectedIndex property.
            if isempty(values)
                error(message('MATLAB:toolstrip:control:invalidSelectedIndex'))
            elseif matlab.ui.internal.toolstrip.base.Utility.validate(values, 'integer') && values == -1
                this.Value = {};
            else
                for ct=1:length(values)
                    value = values(ct);
                    if ~(matlab.ui.internal.toolstrip.base.Utility.validate(value, 'integer') && value >= 1 && value <= size(this.Items,1))
                        error(message('MATLAB:toolstrip:control:invalidSelectedIndex'));
                    end
                end
                this.Value = this.Items(values,1);
            end
        end
        % MultiSelect
        function value = get.MultiSelect(this)
            % GET function for MultiSelect property.
            value = strcmp(this.Action.SelectionMode, 'multiple');
        end
        function set.MultiSelect(this, value)
            % SET function
            OK = matlab.ui.internal.toolstrip.base.Utility.validate(value, 'logical');
            if OK
                if value
                    this.Action.SelectionMode = 'multiple';
                else
                    this.Action.SelectionMode = 'single';
                end
            else
                error(message('MATLAB:toolstrip:control:invalidLogicalProperty', 'MultiSelect'))
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
            rules.properties.MultiSelect = struct('type','logical','isAction',true);            
            rules.input0 = true;
            rules.input1 = {{'Items'}};
            rules.input2 = {{'Items';'MultiSelect'}};
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
            this.Action.addProperty('SelectedItems');
            this.Action.addProperty('SelectionMode');
            this.Action.addCallbackFcn('ItemSelected');
        end
        
        function result = checkAction(this, control) %#ok<INUSL>
            % Abstract method defined in @control
            %
            % specify all the objects that can share action with this one.
            result = isa(control, 'matlab.ui.internal.toolstrip.ListBox');
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
    
    methods (Hidden)
        
        function qeValueChanged(this, items)
            % qeValueChanged(this, items) mimics user selects new items
            % (cell array) in the UI.  "ValueChanged" event is fired with
            % event data.  Note that the Value property of the MCOS
            % object is updated.
            type = 'ValueChanged';
            % generate event data
            data = struct('Property','Value','OldValue',this.Value,'NewValue',items);
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data);
            % commit in MCOS object, which also reflects new value in UI 
            this.Value = items;
            % call ItemSelectedFcn if any
            if ~isempty(findprop(this,'ValueChangedFcn'))
                internal.Callback.execute(this.ValueChangedFcn, this, eventdata);
            end
            % fire event
            this.notify(type, eventdata);
        end
    end
    
end