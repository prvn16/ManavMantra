classdef QABPushButton < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_QuickAccessIcon ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess ...
        & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowText ...
        & matlab.ui.internal.toolstrip.mixin.CallbackFcn_ButtonPushed
    % QAB Push Button
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.impl.QABPushButton.QABPushButton">QABPushButton</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_DescriptionOverride.DescriptionOverride">DescriptionOverride</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon.Icon">Icon</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_IsInQuickAccess.IsInQuickAccess">IsInQuickAccess</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_QuickAccessIcon.QuickAccessIcon">QuickAccessIcon</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Mnemonic.Mnemonic">Mnemonic</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Shortcut">Shortcut</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_ShowText.ShowText">ShowText</a>            
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text.Text">Text</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_TextOverride.TextOverride">TextOverride</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.CallbackFcn_ButtonPushed.ButtonPushedFcn">ButtonPushedFcn</a>                
    %
    % Events:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.impl.QABPushButton.QABPushButton">ButtonPushed</a>        
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    events
        % Event sent upon push button pressed in the view.
        ButtonPushed
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = QABPushButton(varargin)
            % Constructor "QABPushButton": 
            %
            %   Create a QAB push button.
            %
            %   Examples:
            %       qabbtn = matlab.ui.internal.toolstrip.impl.QABButton(btn.getAction())
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('QABPushButton');
            % process custom property
            if nargin==1 && isa(varargin{1},'matlab.ui.internal.toolstrip.base.Action')
                this.setAction(varargin{1});
            else
                this.processCustomProperties(varargin{:});
            end
            % default no text
            this.ShowText = false;
        end
        
    end
    
    %% You must initialize all the abstract methods here
    methods (Access = protected)
        
        function rules = getInputArgumentRules(this)
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
            [mcos3, peer3] = this.getWidgetPropertyNames_ShowText();
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
        
        function result = checkAction(this, control)
            % Abstract method defined in @control
            %
            % specify all the objects that can share action with this one.
            result = isa(control, 'matlab.ui.internal.toolstrip.impl.QABPushButton');
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
    
end
