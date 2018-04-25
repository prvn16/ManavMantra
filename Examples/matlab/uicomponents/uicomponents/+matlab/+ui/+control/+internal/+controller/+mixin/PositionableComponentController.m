classdef (Hidden) PositionableComponentController < ...
        appdesservices.internal.interfaces.controller.AbstractControllerMixin
    % Mixin Controller Class for components with Size, Location, OuterSize,
    % OuterLocation, AspectRatioLimits
    
    % Copyright 2011-2016 The MathWorks, Inc.
    
    methods
        
        function additionalProperties = getAdditonalPositionPropertyNamesForView(obj)  
            additionalProperties = matlab.ui.control.internal.controller.mixin.PositionPropertiesComponentController.getAdditonalPositionPropertyNamesForView(obj.Model);
        end
        
        function viewPvPairs = getPositionPropertiesForView(obj, propertyNames)
            viewPvPairs = matlab.ui.control.internal.controller.mixin.PositionPropertiesComponentController.getPositionPropertiesForView(obj.Model, propertyNames);
        end
        
        function excludedProperties = getExcludedPositionPropertyNamesForView(obj)
            % Get the position related properties that should be excluded
            % from the list of properties sent to the view
            
            % The view only updated Size/Location.
            % Remove Position, Inner/OuterPosition otherwise their peer
            % node value will become stale and also potentially trigger
            % unwanted propertiesSet events (g1396296)
            excludedProperties = {...
                'Position'; ...
                'InnerPosition'; ...
                'OuterPosition'; ...
                };
        end
        
        
    end
    
    methods (Access = 'protected')
        
        function wasHandled = handleEvent(obj, ~, event)
            % HANDLEEVENT is invoked each time a component is repositioned.
            % It allows the view to send the exact position of the inner and/or
            % outer art of the component to the model after the component
            % is repositioned.			
			
			% Flag to keep track if the edit was handled by this controller
			%
			% Returned to caller so that same event is not processed twice
			wasHandled = false;
			
			if(strcmp(event.Data.Name, 'PropertyEditorEdited'))
				
				propertyName = event.Data.PropertyName;
				propertyValue = event.Data.PropertyValue;
				
				if(strcmp(propertyName, 'Position'))
					
					propertyValue = convertClientNumbertoServerNumber(obj, propertyValue);										
					
					setModelProperty(obj, propertyName, propertyValue, event);
					wasHandled = true;
					
				end
			end
			
		end
		
		function changedPropertiesStruct = handlePropertiesChanged(obj, changedPropertiesStruct)
			% Handles Position - related properties changing and
            % Orientation changing
            
            % List of properties that changed
            changedProperties = fieldnames(changedPropertiesStruct);
            
            % Note this is order dependent, Orientation should be handled
            % first            
            if(any(strcmp('Orientation', changedProperties)))
                changedPropertiesStruct = handleOrientationPropertyChange(obj, changedPropertiesStruct);
            end
            
            % Handle Position related properties
            %
            % Ignore the properties Position/InnerPosition/OuterPosition
            % because they are not updated by the view.
            % The view only updates the size/location properties.
            % However, they are still sent from the view when you DnD a new
            % component in the canvas (with non-updated values).
            propertiesToIgnore = {
                'Position',...
                'InnerPosition',...
                'OuterPosition',...
                };
            ignoredPropertiesIndices = isfield(changedPropertiesStruct, propertiesToIgnore);            
            ignoredProperties = propertiesToIgnore(ignoredPropertiesIndices);            
            changedPropertiesStruct = rmfield(changedPropertiesStruct, ignoredProperties);
            
            % Updated list of properties that changed
            changedProperties = fieldnames(changedPropertiesStruct);
            
            % Look for specific Size / Location - related properties
            positionRelatedProperties = {
                'Size', ...
                'Location',...
                'OuterSize', ...
                'OuterLocation',...
                };
            if(any(ismember(positionRelatedProperties, changedProperties)))
                changedPropertiesStruct = handleSizeLocationPropertyChange(obj, changedPropertiesStruct);
            end
            
        end
        
    end
    
    methods(Access = 'protected')
        function changedPropertiesStruct =  handleOrientationPropertyChange(obj, changedPropertiesStruct)
            % While 'Orientation' is not common to all components, the best
            % way to share code amongst orientable gauges and switches was
            % to put that code here.
            
            % Orientation has changed
            %
            % In the Case of Orientation changing, then updated Size /
            % OuterSize values should also be sent to the model            
            newOrientation = changedPropertiesStruct.Orientation;
            
            % Update the component
            obj.Model.handleOrientationChanged(newOrientation);
            
            % Mark orientation as handled
            changedPropertiesStruct = rmfield(changedPropertiesStruct, 'Orientation');
            
            % Properties that changed
            changedProperties = fieldnames(changedPropertiesStruct);
            
            % If the orientation changes from a "wider than tall"
            % to a "taller than wide" form factor (or vice versa), the
            % size constraints might need to be updated.
            % Note: when either AspectRatioLimits or IsSizeFixed is not
            % changed, it is filtered out by the peer node layer so we
            % need to update them separately
            if(any(strcmp('AspectRatioLimits', changedProperties)))
                newAspectRatioLimits = convertClientNumbertoServerNumber(obj, changedPropertiesStruct.AspectRatioLimits);
                obj.Model.handleAspectRatioLimitsChange(newAspectRatioLimits);
                
                % Mark the properties as handled
                changedPropertiesStruct = rmfield(changedPropertiesStruct, 'AspectRatioLimits');
            end
            
            if(any(strcmp('IsSizeFixed', changedProperties)))
                newIsSizeFixed = changedPropertiesStruct.IsSizeFixed;
                obj.Model.handleIsSizeFixedChange(newIsSizeFixed);
                
                % Mark the properties as handled
                changedPropertiesStruct = rmfield(changedPropertiesStruct, 'IsSizeFixed');
            end
            
        end
        
        function changedPropertiesStruct = handleSizeLocationPropertyChange(obj, changedPropertiesStruct)
            % Handles change of Position related properties 
            
            % List of properties that changed
            changedProperties = fieldnames(changedPropertiesStruct);
            
            % Start by building up varaibles with the existing positional
            % state of the model, and then walk through the changed properties and
            % update each variable to the new state.
            newInnerPosition = obj.Model.InnerPosition;
            newOuterPosition = obj.Model.OuterPosition;
            
            % Update each variable by looking at the changed properties
            for idx = 1:length(changedProperties)
                propertyName = changedProperties{idx};
                propertyValue = changedPropertiesStruct.(propertyName);
                
                % Look for specific property changes
                switch(propertyName)                    
                    
                    case 'Location'
                        newInnerPosition(1:2) = propertyValue;
                        
                    case 'Size'
                        newInnerPosition(3:4) = propertyValue;
                        
                    case 'OuterLocation'
                        newOuterPosition(1:2) = propertyValue;
                        
                    case 'OuterSize'
                        newOuterPosition(3:4) = propertyValue;
                end
            end
            
            % Take the updated variables and update the component
            %
            % Note: When we transition Button to using the GBT position
            % mixin, we will need to revisit the call to
            % setPositionFromClient for the button because it causes an
            % assertion failure, see g1515620
            obj.Model.setPositionFromClient('positionChangedEvent', newInnerPosition, newOuterPosition);
            
            % Remove properties that were handled
            positionRelatedProperties = {
                'Size', ...
                'Location',...
                'OuterSize', ...
                'OuterLocation',...
                };
            handledPropertiesLogicalMap = isfield(changedPropertiesStruct, positionRelatedProperties);
            handledPropertyNames = positionRelatedProperties(handledPropertiesLogicalMap);
            
            % Return the unhandled properties
            changedPropertiesStruct = rmfield(changedPropertiesStruct, handledPropertyNames);
            
        end

    end
end
