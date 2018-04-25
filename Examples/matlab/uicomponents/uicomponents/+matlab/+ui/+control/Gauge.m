classdef (ConstructOnLoad=true) Gauge < ...
        matlab.ui.control.internal.model.AbstractScaleDirectionComponent  & ...
        matlab.ui.control.internal.model.mixin.FontStyledComponent 
    %
    
    % Do not remove above white space
    % Copyright 2011-2016 The MathWorks, Inc.
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = Gauge(varargin)
            %

            % Do not remove above white space
            % Ticks related constants
            scaleLineLength = 120;
            
            obj = obj@matlab.ui.control.internal.model.AbstractScaleDirectionComponent(...
                scaleLineLength);

            % Initialize Layout Properties
            defaultSize = [120, 120];
            obj.PrivateInnerPosition(3:4) = defaultSize;
            obj.PrivateOuterPosition(3:4) = defaultSize;
            obj.AspectRatioLimits = [1 1];
            
            obj.Type = 'uigauge';
            
            parsePVPairs(obj,  varargin{:});
            
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
                'Value',...
                'Limits',...
                'MajorTicks',...
                'MajorTickLabels',...
                'ScaleColors',...
                'ScaleColorLimits',...
                'ScaleDirection'};
                
        end
        
        function str = getComponentDescriptiveLabel(obj)
            % GETCOMPONENTDESCRIPTIVELABEL - This function returns a
            % string that will represent this component when the component
            % is displayed in a vector of ui components.

            str = num2str(obj.Value);
        end
    end
end



