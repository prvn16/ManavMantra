classdef (Hidden) PushButtonController < ...
        matlab.ui.control.internal.controller.ComponentController & ...
        matlab.ui.control.internal.controller.mixin.IconableComponentController & ...
        matlab.ui.control.internal.controller.mixin.MultilineTextComponentController & ...
        matlab.ui.control.internal.controller.mixin.LayoutableController
        
    
    % PushButtonController class is the controller class for
    % matlab.ui.control.Lamp object.
    
    % Copyright 2011-2014 The MathWorks, Inc.
    
    methods
        function obj = PushButtonController(varargin)
            obj@matlab.ui.control.internal.controller.ComponentController(varargin{:});
        end
    end
    
    methods(Access = 'protected')
        
        function propertyNames = getAdditionalPropertyNamesForView(obj)
            % Get additional properties to be sent to the view
            
            propertyNames = getAdditionalPropertyNamesForView@matlab.ui.control.internal.controller.ComponentController(obj);
            
            % Non - public properties that need to be sent to the view
            propertyNames = [propertyNames; ...
                matlab.ui.control.internal.controller.mixin.LayoutableController.getAdditonalLayoutPropertyNamesForView(); ...
                ];    
        end
        
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
            
            % Icon Specific
            viewPvPairs = [viewPvPairs, ...
                getIconPropertiesForView(obj, propertyNames);
                ];
            
            % Text
            viewPvPairs = [viewPvPairs, ...
                getTextPropertiesForView(obj, propertyNames);
                ];
            
            % LayoutConstraints
            viewPvPairs = [viewPvPairs, ...
                getLayoutConstraintsForView(obj, propertyNames);
                ];
                        
        end
        
        function handlePropertiesChanged(obj, changedPropertiesStruct)
            % Handles properties changed from client
            
			changedPropertiesStruct = handlePropertiesChanged@matlab.ui.control.internal.controller.mixin.MultilineTextComponentController(obj, changedPropertiesStruct);
            changedPropertiesStruct = handlePropertiesChanged@matlab.ui.control.internal.controller.mixin.IconableComponentController(obj, changedPropertiesStruct);
            handlePropertiesChanged@matlab.ui.control.internal.controller.ComponentController(obj, changedPropertiesStruct);
		end           				
        
        function handleEvent(obj, src, event)
            % Allow super classes to handle their events
            handleEvent@matlab.ui.control.internal.controller.mixin.IconableComponentController(obj, src, event);
            
            % already handled PropertyEditorEdited for Icon
            if ~(strcmp(event.Data.Name, 'PropertyEditorEdited') && strcmp(event.Data.PropertyName, 'Icon'))
                    handleEvent@matlab.ui.control.internal.controller.ComponentController(obj, src, event);
            end
                            
            if(strcmp(event.Data.Name, 'ButtonPushed'))
                % Handles when the user clicks and releases
                % the button
                
                % Create event data
                eventData = matlab.ui.eventdata.ButtonPushedData;

                % Emit 'ButtonPushed' which in turn will trigger the user callback
                obj.handleUserInteraction('ButtonPushed', {'ButtonPushed', eventData});          
            end
        end                
        
    end
            
end


