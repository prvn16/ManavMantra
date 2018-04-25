classdef (ConstructOnLoad=true) Lamp < ...        
        matlab.ui.control.internal.model.ComponentModel & ...
        matlab.ui.control.internal.model.mixin.PositionableComponent & ...
        matlab.ui.control.internal.model.mixin.EnableableComponent & ...
        matlab.ui.control.internal.model.mixin.VisibleComponent
    %
    
    % Do not remove above white space
    % Copyright 2011-2016 The MathWorks, Inc.
    
    properties(Dependent)
        Color@matlab.graphics.datatype.RGBColor = 'green';       
    end
    
    properties(Access = 'protected')
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        % Default is green
        PrivateColor@matlab.graphics.datatype.RGBColor = 'green';        
    end
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = Lamp(varargin)
            
            obj.Type = 'uilamp';
            
            % Initialize Layout Properties            
            defaultSize = [20, 20];
            obj.PrivateInnerPosition(3:4) = defaultSize;
            obj.PrivateOuterPosition(3:4) = defaultSize;
            obj.AspectRatioLimits = [1 1];            					
            
            parsePVPairs(obj,  varargin{:});                        
            
        end    
    end
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        
        function set.Color(obj, newColor)
            
            % Property Setting
            obj.PrivateColor = newColor;
            
            % update view
            obj.markPropertiesDirty({'Color'});
        end
        
        function value = get.Color(obj)
            value = obj.PrivateColor;
        end
    end
    
    
    % ---------------------------------------------------------------------
    % Custom Display Functions
    % ---------------------------------------------------------------------
    methods(Access = protected)
        
        function names = getPropertyGroupNames(obj)
            % GETPROPERTYGROUPNAMES - This function returns common
            % properties for this class that will be displayed in the
            % curated list properties for all components implementing this
            % class.
            
            names = {...
                'Color'};
                
        end
        
        function str = getComponentDescriptiveLabel(obj)
            % GETCOMPONENTDESCRIPTIVELABEL - This function returns a
            % string that will represent this component when the component
            % is displayed in a vector of ui components.
            str = mat2str(obj.Color);
            
        end
    end
    
end
