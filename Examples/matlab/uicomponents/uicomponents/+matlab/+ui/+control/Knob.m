classdef (ConstructOnLoad=true) Knob < ...
        matlab.ui.control.internal.model.AbstractInteractiveTickComponent & ...
         matlab.ui.control.internal.model.mixin.FontStyledComponent     
    %
    
    % Do not remove above white space
    % Copyright 2011-2016 The MathWorks, Inc.
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = Knob(varargin)
            %

            % Do not remove above white space
            %Tick related constants
            scaleLineLength = 200;
            
            obj = obj@matlab.ui.control.internal.model.AbstractInteractiveTickComponent(...
                scaleLineLength);                           			

            % Initialize Layout Properties
            locationOffset = [26 19];
            obj.PrivateOuterPosition(1:2) = obj.PrivateInnerPosition(1:2) - locationOffset;
            obj.PrivateOuterPosition(3:4) = [114 103];
            obj.PrivateInnerPosition(3:4) = [60 60];            
            obj.AspectRatioLimits = [1 1];
            
            obj.Type = 'uiknob';
            
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
                ...Callbacks
                'ValueChangedFcn', ...
                'ValueChangingFcn'};
                
        end
        
        function str = getComponentDescriptiveLabel(obj)
            % GETCOMPONENTDESCRIPTIVELABEL - This function returns a
            % string that will represent this component when the component
            % is displayed in a vector of ui components.
            
            str = num2str(obj.Value);
        end
    end
end

