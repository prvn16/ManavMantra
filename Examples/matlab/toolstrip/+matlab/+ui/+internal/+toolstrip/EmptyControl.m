classdef EmptyControl < matlab.ui.internal.toolstrip.base.Component
    % Empty Control
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.EmptyControl.EmptyControl">EmptyControl</a>    
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
    % See also matlab.ui.internal.toolstrip.Column
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% ----------- Developer API  ----------------------
        function this = EmptyControl(varargin)
            % Creates an empty control.
            %
            % Example:
            %   obj = matlab.ui.internal.toolstrip.EmptyControl()
            %   column.add(obj);
            
            % set type
            this.Type = 'EmptyControl';
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

