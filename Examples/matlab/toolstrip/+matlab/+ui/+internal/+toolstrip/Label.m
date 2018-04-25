classdef Label < matlab.ui.internal.toolstrip.base.Control ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text ...
        & matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon
    % Text and Icon Label
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Label.Label">Label</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Description">Description</a>    
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Control.Enabled">Enabled</a>  
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Icon.Icon">Icon</a>        
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.ActionBehavior_Text.Text">Text</a>        
    %
    % Methods:
    %   N/A
    %
    % Events:
    %   N/A
    %
    % See also matlab.ui.internal.toolstrip.Icon
    
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

    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = Label(varargin)
            % Constructor "Label": 
            %
            %   Create a label.
            %
            %   Example:
            %       text = 'Open';
            %       icon = matlab.ui.internal.toolstrip.Icon.OPEN_16;
            %       lbl = matlab.ui.internal.toolstrip.Label
            %       lbl = matlab.ui.internal.toolstrip.Label(icon)
            %       lbl = matlab.ui.internal.toolstrip.Label(text)
            %       lbl = matlab.ui.internal.toolstrip.Label(text, icon)
            
            % super
            this = this@matlab.ui.internal.toolstrip.base.Control('Label');
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
            [mcos, peer] = this.getWidgetPropertyNames_Control();
            this.WidgetPropertyMap_FromMCOSToPeer = containers.Map(mcos, peer);
            this.WidgetPropertyMap_FromPeerToMCOS = containers.Map(peer, mcos);
        end
        
        function addActionProperties(this)
            % Abstract method defined in @control
            %
            % add action properties to Action object as dynamic properties.
            this.Action.addProperty('Text');
            this.Action.addProperty('Icon');
        end
        
        function result = checkAction(this, control) %#ok<INUSL>
            % Abstract method defined in @control
            %
            % specify all the objects that can share action with this one.
            result = isa(control, 'matlab.ui.internal.toolstrip.Label');
        end
        
    end
    
end

