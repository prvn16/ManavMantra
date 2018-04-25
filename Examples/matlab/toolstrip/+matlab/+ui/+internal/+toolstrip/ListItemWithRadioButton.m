classdef ListItemWithRadioButton < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_ButtonGroup ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowText ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowDescription ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Selected ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_SelectionChanged
    % List Item with Radio Button
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListItemWithRadioButton.ListItemWithRadioButton">ListItemWithRadioButton</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_ButtonGroup.ButtonGroup">ButtonGroup</a>       
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowDescription.ShowDescription">ShowDescription</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowText.ShowText">ShowText</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text.Text">Text</a>      
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Selected.Value">Value</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_SelectionChanged.ValueChangedFcn">ValueChangedFcn</a>            
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.ListItemWithRadioButton.ValueChanged">ValueChanged</a>            
    %
    % See also matlab.ui.internal.toolstrip.PopupList, matlab.ui.internal.toolstrip.Radiobutton
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    events
        % Event triggered by selecting the radio button in the UI.
        ValueChanged
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = ListItemWithRadioButton(varargin)
            % Constructor "ListItemWithRadioButton": 
            %
            %   Creates a list item with radio button
            %
            %   Examples:
            %       group = matlab.ui.internal.toolstrip.ButtonGroup;
            %       item1 = matlab.ui.internal.toolstrip.ListItemWithRadioButton(group, 'red');
            %       item2 = matlab.ui.internal.toolstrip.ListItemWithRadioButton(group, 'green');
            %       item3 = matlab.ui.internal.toolstrip.ListItemWithRadioButton(group, 'blue');

            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('ListItemWithRadioButton');
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
            [mcos1, peer1] = this.getWidgetPropertyNames_Control();
            [mcos2, peer2] = this.getWidgetPropertyNames_ShowText();
            [mcos3, peer3] = this.getWidgetPropertyNames_ShowDescription();
            mcos = [mcos1;mcos2;mcos3];
            peer = [peer1;peer2;peer3];
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
            result = isa(control, 'matlab.ui.internal.toolstrip.ListItemWithRadioButton') ...
                || isa(control, 'matlab.ui.internal.toolstrip.RadioButton');        
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
            
            % itself
            render@matlab.ui.internal.toolstrip.base.Control(this, channel, parent, varargin{:});
            % set button group id
            this.Action.setPeerProperty('buttonGroupName',this.ButtonGroup.Id);
        end
        
    end
    
end
