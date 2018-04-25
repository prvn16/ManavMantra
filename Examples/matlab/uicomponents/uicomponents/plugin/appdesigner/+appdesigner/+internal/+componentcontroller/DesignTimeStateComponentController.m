classdef DesignTimeStateComponentController < ...
		matlab.ui.control.internal.controller.StateComponentController & ...
		appdesigner.internal.componentcontroller.DesignTimeVisualComponentsController
	%DESIGNTIMESTATECOMPONENTCONTROLLER - This class contains design time logic
	%specific to components like the drop down
	
	
	methods
		function obj = DesignTimeStateComponentController(component, parentController, proxyView)
			obj = obj@matlab.ui.control.internal.controller.StateComponentController(component, parentController, proxyView);
			obj = obj@appdesigner.internal.componentcontroller.DesignTimeVisualComponentsController(component, proxyView);
			
			% Destroy the visual comopnent's runtime listeners.  We will
			% not be needing these during design time.
			delete(obj.Listeners);
			obj.Listeners = [];
			
		end
	end
	
	methods (Access = 'protected')
		
		function handleDesignTimePropertiesChanged(obj, src, changedPropertiesStruct)
			% HANDLEDESIGNTIMEPROPERTIESCHANGED - Delegates the logic of
			% handling the event to the runtime controllers via the
			% handlePropertiesChanged method
			handlePropertiesChanged(obj, changedPropertiesStruct);
		end
		
		function handleDesignTimeEvent(obj, src, event)
			% HANDLEDESIGNTIMEEVENT - Delegates the logic of handling the
			% event to the runtime controllers via the handleEvent method
						
			if(strcmp(event.Data.Name, 'PropertyEditorEdited'))
				% Handle changes in the property editor that needs a
				% server side validation
				
				propertyName = event.Data.PropertyName;
				propertyValue = event.Data.PropertyValue;				
				
				if(any(strcmp(propertyName, {'Value', 'Items'})))
					
					if(isempty(propertyValue) && isnumeric(propertyValue))
						% g1416534						
						%
						% Note if g1426526 is fixed, then this assumption
						% that value needs {} and not [] may break.
						propertyValue = {};
						
						% Update the event data in line
						setModelProperty(obj, ...
							propertyName, ...
							propertyValue, ...
							event ...
							);
						
						return;
						
					end															
				end
			end
			
			% Defer to super otherwise
			%
			% The property edit does not need to be specially
			% handled
			handleEvent(obj, src, event);
		end
		
		function changedPropertiesStruct = handleSizeLocationPropertyChange(obj, changedPropertiesStruct)
			% Handles change of Position related properties
			% Override of the method defined in
			% PositionableComponentController (runtime)
			
			% Call super first
			changedPropertiesStruct = handleSizeLocationPropertyChange@matlab.ui.control.internal.controller.mixin.PositionableComponentController(obj, changedPropertiesStruct);
			
			% Design time specific business logic
			% This needs to be done after the call to super because the run
			% time method will update Position / InnerPosition /
			% OuterPosition, and the set below relies on those properties
			% being updated
			%
			% To keep Position up to date in the client, need to
			% update it after things like move, resize , etc...
			obj.ProxyView.setProperties({
				'Position', obj.Model.Position, ...
				'InnerPosition', obj.Model.InnerPosition, ...
				'OuterPosition', obj.Model.OuterPosition});
		end
		
	end
	
	methods
		
		function excludedProperties = getExcludedPositionPropertyNamesForView(obj)
			% Get the position related properties that should be excluded
			% from the list of properties sent to the view
			
			excludedProperties = getExcludedPositionPropertyNamesForView@matlab.ui.control.internal.controller.mixin.PositionableComponentController(obj);
			
			% The runtime controller removes Position, Inner/OuterPosition.
			% Since those properties need to be sent to the view at design
			% time (e.g. for the inspector), remove those properties from
			% the list of excluded properties
			positionProperties = {...
				'Position', ...
				'InnerPosition', ...
				'OuterPosition', ...
				};
			
			excludedProperties = setdiff(excludedProperties, positionProperties);
		end
		
	end
end

