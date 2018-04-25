classdef (Hidden) BinaryComponentController < ...
        matlab.ui.control.internal.controller.ComponentController
    
    % Copyright 2011-2014 The MathWorks, Inc.    
    methods
        function obj = BinaryComponentController(varargin)                      
            obj@matlab.ui.control.internal.controller.ComponentController(varargin{:});
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
                getPropertiesForView@matlab.ui.control.internal.controller.ComponentController(obj, propertyNames), ...
                ];            
                                                                                          
        end
        
        function handleEvent(obj, src, event)
            % Allow super classes to handle their events
            handleEvent@matlab.ui.control.internal.controller.ComponentController(obj, src, event);            
			
			if(strcmp(event.Data.Name, 'ValueChanged'))
				% Handles user clicking on the component
				
                % Store the previous value
                previousValue = obj.Model.Value;
                
                newValue = event.Data.Value;
                
                % Create event data
                eventData = matlab.ui.eventdata.ValueChangedData(newValue, previousValue);
            
                % Update the model and emit an event which in turn will 
                % trigger the user callback
				obj.handleUserInteraction('ValueChanged', {'ValueChanged', eventData, 'PrivateValue', newValue});                
			end
			
        end
    end
end


