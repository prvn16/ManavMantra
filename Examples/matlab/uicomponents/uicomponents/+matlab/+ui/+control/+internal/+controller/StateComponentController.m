classdef (Hidden) StateComponentController < ...
        matlab.ui.control.internal.controller.ComponentController
    
    % STATECOMPONENTCONTROLLER This is controller class for any component
    % with state related properties
    
    % Copyright 2011-2012 The MathWorks, Inc.
    
    methods
        function obj = StateComponentController(varargin)
            obj@matlab.ui.control.internal.controller.ComponentController(varargin{:});
        end
    end
    
    methods(Access = 'protected')
        
        function propertyNames = getAdditionalPropertyNamesForView(obj)
            % Get additional properties to be sent to the view
            
            propertyNames = getAdditionalPropertyNamesForView@matlab.ui.control.internal.controller.ComponentController(obj);
            
            % Non - public properties that need to be sent to the view
            propertyNames = [propertyNames; {...
                'SelectedIndex';...                
                }];    
        end
        
        function handleEvent(obj, src, event)
            % HANDLEEVENT(OBJ, ~, EVENT) this method is invoked each time
            % user changes the state of the component
            
            handleEvent@matlab.ui.control.internal.controller.ComponentController(obj, src, event);
            
            if(strcmp(event.Data.Name, 'StateChanged'))
                % The state of the component has changed
                
                % 1-based index indicating the selected item
                selectedIndex = event.Data.SelectedIndex;
                
                % Store the previous value
                previousValue = obj.Model.Value;
                                
                % value and valuedata for the new index
                value = obj.Model.getValueGivenIndex(selectedIndex);
                                
                % Create event data with additional property ValueData
                eventData = matlab.ui.eventdata.ValueChangedData(...
                    value, ...
                    previousValue);
                
                % Update the model and emit an event which in turn will 
                % trigger the user callback
                % Setting PrivateSelectedIndex will result in the value
                % property stored on the peernode to be out of sync.  The
                % Value property on the peernode should not be used by
                % anyone at runtime.  This issue only exists at runtime
                % because this code is only hit when users are interacting
                % with the component.
				obj.handleUserInteraction('StateChanged', {'ValueChanged', eventData, 'PrivateSelectedIndex', selectedIndex});                
            end
            
        end        
            
        function changedPropertiesStruct = handlePropertiesChanged(obj, changedPropertiesStruct)
            
            % Handle a batch update of Items and SelectedIndex
            % The Items property will be set first            
            % If Items is empty, it will be passed to the server as [], so
            % we need to convert it to {}            
            if(isfield(changedPropertiesStruct, 'Items'))
                newItems = changedPropertiesStruct.Items;
                if(isa(newItems, 'double'))
                    newItems = num2cell(newItems);
                end
                obj.Model.handleItemsChanged(newItems);
                changedPropertiesStruct = rmfield(changedPropertiesStruct, 'Items');
            end
            
            % Handle SelectedIndex since it is not a public property 
            if(isfield(changedPropertiesStruct, 'SelectedIndex'))
                newSelectedIndex = changedPropertiesStruct.SelectedIndex;                
                obj.Model.SelectedIndex = newSelectedIndex;
                changedPropertiesStruct = rmfield(changedPropertiesStruct, 'SelectedIndex');
            end
            
            % Remove Value and do not handle from Property Sheet
            if(isfield(changedPropertiesStruct, 'Value'))     
                changedPropertiesStruct = rmfield(changedPropertiesStruct, 'Value');
            end            
        
            % superclass method
            handlePropertiesChanged@matlab.ui.control.internal.controller.ComponentController(obj, changedPropertiesStruct);
            
        end
    end
    
    
end

