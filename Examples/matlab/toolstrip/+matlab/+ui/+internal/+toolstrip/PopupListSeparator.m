classdef PopupListSeparator < matlab.ui.internal.toolstrip.base.Component
    % Popup List Separator
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.PopupListSeparator.PopupListSeparator">PopupListSeparator</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.base.Component.Tag">Tag</a>
    %
    % Methods:
    %   N/A
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
        
        %% ----------- Developer API  ----------------------
        function this = PopupListSeparator(varargin)
            % Constructor "PopupListSeparator": 
            %
            %   Creates a popup list separator
            %
            %   Examples:
            %       separator = matlab.ui.internal.toolstrip.PopupListSeparator();
            %       popup.add(separator)
            
            % set type
            this.Type = 'PopupListSeparator';
            % create widget property maps (action properties are handled
            % inside the Action object)
            this.buildWidgetPropertyMaps();
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
            rules.input0 = true;
        end
        
        function buildWidgetPropertyMaps(this)
            % Abstract method defined in @component
            %
            % build maps between private MCOS property names and peer node
            % property names for widget properties.  The map for action
            % properties are automatically built when creating Action
            % object.
            [mcos, peer] = this.getWidgetPropertyNames_Component();
            this.WidgetPropertyMap_FromMCOSToPeer = containers.Map(mcos, peer);
            this.WidgetPropertyMap_FromPeerToMCOS = containers.Map(peer, mcos);
        end
        
    end
    
end

