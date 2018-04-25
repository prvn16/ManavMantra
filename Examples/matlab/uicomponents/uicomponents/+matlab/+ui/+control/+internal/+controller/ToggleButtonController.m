classdef (Hidden) ToggleButtonController < ...
        matlab.ui.control.internal.controller.MutualExclusiveComponentController & ...
        matlab.ui.control.internal.controller.mixin.IconableComponentController & ...
        matlab.ui.control.internal.controller.mixin.MultilineTextComponentController
    
    % Copyright 2013 The MathWorks, Inc.   
    
    methods
        function obj = ToggleButtonController(varargin)                      
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
            
            % Icon Specific
            viewPvPairs = [viewPvPairs, ...
                getIconPropertiesForView(obj, propertyNames);
                ];
            
            % Text related
            viewPvPairs = [viewPvPairs, ...
                getTextPropertiesForView(obj, propertyNames);
                ];                                                                                           
        end

        function handleEvent(obj, src, event)
            % Allow super classes to handle their events
            handleEvent@matlab.ui.control.internal.controller.mixin.IconableComponentController(obj, src, event);
            handleEvent@matlab.ui.control.internal.controller.MutualExclusiveComponentController(obj, src, event);

            % already handled PropertyEditorEdited for Icon
            if ~(strcmp(event.Data.Name, 'PropertyEditorEdited') && strcmp(event.Data.PropertyName, 'Icon'))
                handleEvent@matlab.ui.control.internal.controller.ComponentController(obj, src, event);
            end            
        end
        
        function handlePropertiesChanged(obj, changedPropertiesStruct)
            % Handles properties changed from client            
            changedPropertiesStruct = handlePropertiesChanged@matlab.ui.control.internal.controller.mixin.IconableComponentController(obj, changedPropertiesStruct);
			changedPropertiesStruct = handlePropertiesChanged@matlab.ui.control.internal.controller.mixin.MultilineTextComponentController(obj, changedPropertiesStruct);
            handlePropertiesChanged@matlab.ui.control.internal.controller.ComponentController(obj, changedPropertiesStruct);
        end
    end
end



