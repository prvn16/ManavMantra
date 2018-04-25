classdef PopupListHeader < matlab.ui.internal.toolstrip.base.Component & matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Title
    % Popup List Header
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PopupListHeader.PopupListHeader">PopupListHeader</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %   <a href="matlab:help matlab.ui.internal.toolstrip.mixin.WidgetBehavior_Title.Title">Title</a>        
    %
    % Events:
    %   N/A
    %
    % See also matlab.ui.internal.toolstrip.PopupList
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Constructor
        function this = PopupListHeader(varargin)
            % Constructor "PopupListHeader": 
            %
            %   Creates a popup header in a popup list
            %
            %   Examples:
            %       header = matlab.ui.internal.toolstrip.base.PopupListHeader('Simulink Products');

            % set type
            this.Type = 'PopupListHeader';
            % create widget property maps
            this.buildWidgetPropertyMaps();
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
            rules.properties.Title = struct('type','string','isAction',false);
            rules.input0 = true;
            rules.input1 = {{'Title'}};
        end
        
        function buildWidgetPropertyMaps(this)
            % Abstract method defined in @component
            %
            % build maps between private MCOS property names and peer node
            % property names for widget properties.  The map for action
            % properties are automatically built when creating Action
            % object.
            [mcos1, peer1] = this.getWidgetPropertyNames_Component();
            [mcos2, peer2] = this.getWidgetPropertyNames_Title();
            mcos = [mcos1;mcos2];
            peer = [peer1;peer2];
            this.WidgetPropertyMap_FromMCOSToPeer = containers.Map(mcos, peer);
            this.WidgetPropertyMap_FromPeerToMCOS = containers.Map(peer, mcos);
        end
        
    end
    
end
