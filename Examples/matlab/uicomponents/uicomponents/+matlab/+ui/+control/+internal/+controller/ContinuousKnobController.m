classdef (Hidden) ContinuousKnobController < matlab.ui.control.internal.controller.InteractiveTickComponentController
    % ContinuousKnobController controller for ContinuousKnob
    
    % Copyright 2011-2012 The MathWorks, Inc.
    
    methods
        function obj = ContinuousKnobController(varargin)            
            obj@matlab.ui.control.internal.controller.InteractiveTickComponentController(varargin{:});
        end
    end
    
    methods(Access = 'protected')                        
        
        function componentValue = convertViewValueToComponentValue(obj, viewValue)
            % Override the default behavior because the view does not send
            % the actual component's value 
            
            % The view returns a scaled position of the needle from
            % 0-1, where 0 means that the needle is pointing to the
            % minimum value(lower left) and 1 means that the needle
            % is pointing to maximum(lower right). convert this
            % scaling factor to the value.
            limits = obj.Model.Limits;

            % scale range represents the magnitude of the  "span"
            % of the scale limits, meaning the overall distance
            % between the min and the max
            scaleRange = abs(limits(2) - limits(1));                    

            % new value is how far along the scale range the user
            % rotated the needle
            componentValue = scaleRange * viewValue + limits(1);
        end
        
    end
    
end

