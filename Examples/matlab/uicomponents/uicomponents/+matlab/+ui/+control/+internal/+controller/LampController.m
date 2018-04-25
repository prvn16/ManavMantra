classdef (Hidden) LampController < ...
        matlab.ui.control.internal.controller.ComponentController
    % LAMPCONTROLLER class is the controller class for
    % matlab.ui.control.Lamp object.
    
    % Copyright 2011-2012 The MathWorks, Inc.
    
    methods
        function obj = LampController(varargin)
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
            
            % Lamp - specific
            if(any(strcmp('Color', propertyNames)))

                % Scale the values of color to 0 - 255
                colorValue = round(255 * obj.Model.Color);
                
                viewPvPairs = [viewPvPairs, ...
                    {'Color', colorValue}, ...
                    ];
            end
                        
        end
        
        % Handle Lamp specific property sets
        function changedPropertiesStruct = handlePropertiesChanged(obj, changedPropertiesStruct)
            
            % Figure out what properties changed
            changedProperties = fieldnames(changedPropertiesStruct);
            
            index = find(strcmp('Color', changedProperties), 1);
            
            if(~isempty(index))                
                % Convert the Color to values on a scale of 0-1 from
                % 0-255
                newColor = changedPropertiesStruct.Color / 255;
                % Set the corrected value of stateColors on the MATLAB
                % model
                obj.Model.Color = round(newColor, 4);
                % Remove the Color field from the struct since it has
                % been handled already
                changedPropertiesStruct = rmfield(changedPropertiesStruct, 'Color');
            end
            
            % Call the superclass for unhandled properties
            handlePropertiesChanged@matlab.ui.control.internal.controller.ComponentController(obj, changedPropertiesStruct);
            
        end
    end
       
end


