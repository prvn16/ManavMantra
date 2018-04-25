classdef (Hidden) RadioButtonController < ...
        matlab.ui.control.internal.controller.MutualExclusiveComponentController & ...
        matlab.ui.control.internal.controller.mixin.MultilineTextComponentController
    
    % Copyright 2013 The MathWorks, Inc.   
    
    methods
        function obj = RadioButtonController(varargin)                      
            obj@matlab.ui.control.internal.controller.MutualExclusiveComponentController(varargin{:});
        end
    end
    
    methods(Access = 'protected')                
        
        function viewPvPairs = getPropertiesForView(obj, propertyNames)
            % GETPROPERTIESFORVIEW(OBJ, PROPERTYNAME) returns view-specific
            % properties, given the PROPERTYNAMES
            %
            % Inputs:
            %
            %   propertyNames - list of properties that changed in the
            %                   component model.
            %
            % Outputs:
            %
            %   viewPvPairs   - list of {name, value, name, value} pairs
            %                   that should be given to the view.
            
            
            viewPvPairs = {};                        
            
            % Properties from Super
            viewPvPairs = [viewPvPairs, ...
                getPropertiesForView@matlab.ui.control.internal.controller.MutualExclusiveComponentController(obj, propertyNames), ...
                ];            
            
            % Text related
            viewPvPairs = [viewPvPairs, ...
                getTextPropertiesForView(obj, propertyNames);
                ];                                                                                           
		end
		
		function handlePropertiesChanged(obj, changedPropertiesStruct)									
			% defer to mixin and super class
			changedPropertiesStruct = handlePropertiesChanged@matlab.ui.control.internal.controller.mixin.MultilineTextComponentController(obj, changedPropertiesStruct);
            handlePropertiesChanged@matlab.ui.control.internal.controller.ComponentController(obj, changedPropertiesStruct);
		end                
    end
end


