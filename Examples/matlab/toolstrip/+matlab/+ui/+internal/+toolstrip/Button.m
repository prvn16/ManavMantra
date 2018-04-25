classdef Button < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_QuickAccessIcon ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_ButtonPushed
    % Push Button
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Button.Button">Button</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon.Icon">Icon</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text.Text">Text</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_ButtonPushed.ButtonPushedFcn">ButtonPushedFcn</a>                
    %
    % Methods:
    %   N/A
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Button.ButtonPushed">ButtonPushed</a>        
    %
    % See also matlab.ui.internal.toolstrip.ListItem, matlab.ui.internal.toolstrip.SplitButton

    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    % -----------------------------------------------------------------------------------------
    % ATTENTION: the following settings are only valid for JavaScript rendering
    %   Properties:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride.DescriptionOverride">DescriptionOverride</a>        
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_IconOverride.IconOverride">IconOverride</a>        
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess.IsInQuickAccess">IsInQuickAccess</a>        
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_QuickAccessIcon.QuickAccessIcon">QuickAccessIcon</a>        
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride.TextOverride">TextOverride</a>        
    %   Methods:
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess.addToQuickAccess">addToQuickAccess</a>    
    %       <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess.removeFromQuickAccess">removeFromQuickAccess</a>    
    %       <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.shareWith">shareWith</a>    
    %   Events:
    %       N/A
    % -----------------------------------------------------------------------------------------
    
    events
        % Event triggered by pushing the button in the UI.
        ButtonPushed
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = Button(varargin)
            % Constructor "Button": 
            %
            %   Create a push button.
            %
            %   Examples:
            %       text = 'Open';
            %       icon = matlab.ui.internal.toolstrip.Icon.OPEN_24;
            %       btn = matlab.ui.internal.toolstrip.Button
            %       btn = matlab.ui.internal.toolstrip.Button(text)
            %       btn = matlab.ui.internal.toolstrip.Button(icon)
            %       btn = matlab.ui.internal.toolstrip.Button(text,icon)
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('PushButton');
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
            rules.properties.Icon = struct('type','Icon','isAction',true);
            rules.input0 = true;
            rules.input1 = {{'Text'};{'Icon'}};
            rules.input2 = {{'Text';'Icon'}};
        end
        
        function buildWidgetPropertyMaps(this)
            % Abstract method defined in @component
            %
            % build maps between private MCOS property names and peer node
            % property names for widget properties.  The map for action
            % properties are automatically built when creating Action
            % object.
            [mcos1, peer1] = this.getWidgetPropertyNames_Control();
            [mcos2, peer2] = this.getWidgetPropertyNames_TextOverride();
            [mcos3, peer3] = this.getWidgetPropertyNames_IconOverride();
            [mcos4, peer4] = this.getWidgetPropertyNames_DescriptionOverride();
            mcos = [mcos1;mcos2;mcos3;mcos4];
            peer = [peer1;peer2;peer3;peer4];
            this.WidgetPropertyMap_FromMCOSToPeer = containers.Map(mcos, peer);
            this.WidgetPropertyMap_FromPeerToMCOS = containers.Map(peer, mcos);
        end
        
        function addActionProperties(this)
            % Abstract method defined in @control
            %
            % add action properties to Action object as dynamic properties.
            this.Action.addProperty('Text');
            this.Action.addProperty('Icon');
            this.Action.addProperty('QuickAccessIcon');
            this.Action.addProperty('IsInQuickAccess');
            this.Action.addCallbackFcn('PushPerformed');
        end
        
        function result = checkAction(this, control) %#ok<INUSL>
            % Abstract method defined in @control
            %
            % specify all the objects that can share action with this one.
            result = isa(control, 'matlab.ui.internal.toolstrip.Button') ...
                || isa(control, 'matlab.ui.internal.toolstrip.impl.QABPushButton') ...
                || isa(control, 'matlab.ui.internal.toolstrip.ListItem');
        end
        
    end
    
    %% You must put all the overloaded methods here
    methods (Access = protected)
        
        function ActionPerformedCallback(this, ~, ~)
            % Overloaded method defined in @control
            %
            this.notify('ButtonPushed');
        end
        
    end
    
    %% QE methods
    methods (Hidden)
        
        function qePushed(this)
            % qeButtonPushed(this) mimics user pushes the
            % button in the UI.  "ButtonPushed" event is fired.
            type = 'ButtonPushed';
            % call ButtonPushedFcn if any
            if ~isempty(findprop(this,'ButtonPushedFcn'))
                internal.Callback.execute(this.ButtonPushedFcn, this);
            end
            % fire event
            this.notify(type);
        end
        
    end
    
end
