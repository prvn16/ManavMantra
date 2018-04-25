classdef ListItemWithEditField < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Editable ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Label ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_PlaceholderText ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_EditableText ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_TextChanged
    % List Item with Edit Field
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListItemWithEditField.ListItemWithEditField">ListItemWithEditField</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Editable.Editable">Editable</a>      
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Label.Text">Text</a>      
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_PlaceholderText.PlaceholderText">PlaceholderText</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_EditableText.Value">Value</a>      
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_TextChanged.ValueChangedFcn">ValueChangedFcn</a>            
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListItemWithEditField.ValueChanged">ValueChanged</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListItemWithEditField.TextCancelled">TextCancelled</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListItemWithEditField.FocusGained">FocusGained</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListItemWithEditField.FocusLost">FocusLost</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListItemWithEditField.Typing">Typing</a>
    %
    % See also matlab.ui.internal.toolstrip.PopupList, matlab.ui.internal.toolstrip.CheckBox
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    events
        ValueChanged
        TextCancelled
        FocusGained
        FocusLost
        Typing
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = ListItemWithEditField(varargin)
            % Constructor "ListItemWithEditField": 
            %
            %   Creates a list item with check box
            %
            %   Examples:
            %       lbl = 'Number of lines:';
            %       value = '10';
            %       placeholder = 'Enter an integer here';
            %       item = matlab.ui.internal.toolstrip.ListItemWithEditField(lbl);
            %       item = matlab.ui.internal.toolstrip.ListItemWithEditField(lbl, value);
            %       item = matlab.ui.internal.toolstrip.ListItemWithEditField(lbl, value, placeholder);

            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('ListItemWithTextField');
            % process custom property
            this.processCustomProperties(varargin{:});
            % default is editable
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
            rules.properties.Text = struct('type','string','isAction',true);
            rules.properties.Value = struct('type','string','isAction',true);
            rules.properties.PlaceholderText = struct('type','string','isAction',true);
            rules.input0 = true;
            rules.input1 = {{'Text'}};
            rules.input2 = {{'Text';'Value'}};
            rules.input3 = {{'Text';'Value';'PlaceholderText'}};
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
            this.Action.addProperty('Label');
            this.Action.addProperty('Text');
            this.Action.addProperty('PlaceholderText');
            this.Action.addProperty('Editable');
            this.Action.addCallbackFcn('TextChanged');
        end
        
        function result = checkAction(this, control) %#ok<INUSL>
            % Abstract method defined in @control
            %
            % specify all the objects that can share action with this one.
            result = isa(control, 'matlab.ui.internal.toolstrip.ListItemWithEditField');
        end
        
    end
    
    %% You must put all the overloaded methods here
    methods (Access = protected)
        
        function ActionPerformedCallback(this, ~, data)
            type = data.EventData.EventType;
            if any(strcmp(type,{'ValueChanged','TextCancelled','FocusGained','FocusLost','Typing'}))
                eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(rmfield(data.EventData,'EventType'));
                this.notify(type, eventdata);
            end
        end
        
        function ActionPropertySetCallback(this, ~, data)
            eventdata = matlab.ui.internal.toolstrip.base.ToolstripEventData(data.EventData);
            if strcmp(eventdata.EventData.Property,'Value')
                this.notify('ValueChanged',eventdata);   
            end
        end
        
    end
    
end
