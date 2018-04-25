classdef DesignTimeGaugeComponentController < ...
        matlab.ui.control.internal.controller.GaugeComponentController & ...
        appdesigner.internal.componentcontroller.DesignTimeVisualComponentsController
    %DESIGNTIMEGAUGECOMPONENTCONTROLLER - This class contains design time logic
    %specific to the gauge
    
    
    methods
        function obj = DesignTimeGaugeComponentController(component, parentController, proxyView)
            obj = obj@matlab.ui.control.internal.controller.GaugeComponentController(component, parentController, proxyView);
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
				
                % same logic in ScaleColorsEditor.m
                % when app designer switch to server driven, these logic
                % can be removed, because we can get the value conversion
                % for free.
				if(any(strcmp(propertyName, {'ScaleColors', 'ScaleColorLimits'})))
                    if iscell(propertyValue)
                        propertyValue = cell2mat(propertyValue);
                    else
                        try
                            propertyValue = evalin('base', ['[' propertyValue ']']);
                            if ischar(propertyValue)
                                propertyValue = evalin('base', ['{' propertyValue '}']);
                            end
                        catch
                            % do nothing, the property value will be passed
                            % into model, let model handle the value.
                        end
                        
                        if strcmp(propertyName, 'ScaleColors') && ...
                                ((ischar(propertyValue) && isvector(propertyValue)) || (isstring(propertyValue) && isscalar(propertyValue)))
                            % Convert ' r, g b ' to {'r' 'g' 'b'} for colors
                            propertyValue = strsplit(strtrim(propertyValue), ',|;|\s*', ...
                                'DelimiterType', 'RegularExpression');
                        elseif strcmp(propertyName, 'ScaleColorLimits') && ...
                                isvector(propertyValue) && length(propertyValue) > 2 && isnumeric(propertyValue)
                            % Convert [1 2 3 4] to [1 2; 2 3; 3 4] for limits
                            lims = ones(length(propertyValue) - 1, 2);
                            for i = 1:length(propertyValue) - 1
                                lims(i, :) = propertyValue(i:i+1);
                            end
                            propertyName = lims;
                        end
                    end
                    
 					setModelProperty(obj, ...
							propertyName, ...
							propertyValue, ...
							event ...
							);
						
						return;														
				end
			end
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

