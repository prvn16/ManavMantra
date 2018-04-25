classdef (Hidden) DropDownController < ...
        matlab.ui.control.internal.controller.StateComponentController
    
    % DropDownController: This is the controller for the object
    % matlab.ui.control.DropDown. 
    
    
    % Copyright 2011-2015 The MathWorks, Inc.

    methods
        function obj = DropDownController(varargin)           
            obj@matlab.ui.control.internal.controller.StateComponentController(varargin{:});
        end
    end
   
    methods(Access = 'protected')               
        
		% Override the super's handleEvent
        function handleEvent(obj, src, event)
            % HANDLEEVENT(OBJ, ~, EVENT) this method is invoked each time
            % user changes the state of the component
            
            % Do not call the direct super because this class needs to
            % handle the event 'StateChanged' differently
            handleEvent@matlab.ui.control.internal.controller.ComponentController(obj, src, event);
            
            if(strcmp(event.Data.Name, 'StateChanged'))
                % The state of the component has changed
                % The structure of the event.Data is:
                %  - SelectedIndex: index (1-based) if selection, string if user edit
                %  - SelectedIndex: index (1-based) if selection, string if user edit
                
                
                % new selected index and corresponding value and valuedata
                newSelectedIndex = event.Data.SelectedIndex;
                newValue = obj.Model.getValueGivenIndex(newSelectedIndex);
                                
                % whether the new value is a string 
                isNewValueEdited = matlab.ui.control.internal.model.PropertyHandling.isString(newSelectedIndex);
                    
                % previously selected index and corresponding value and
                % valuedata
                previousSelectedIndex = event.Data.PreviousSelectedIndex;                
                previousValue = obj.Model.getValueGivenIndex(previousSelectedIndex);
                
                
                % Create event data with additional properties 
                eventData = matlab.ui.eventdata.ValueChangedData(...
                    newValue, ...
                    previousValue, ...
                    'Edited', isNewValueEdited);
                
                % Update the model and emit an event which in turn will 
                % trigger the user callback
				obj.handleUserInteraction('StateChanged', {'ValueChanged', eventData, 'PrivateSelectedIndex', newSelectedIndex});                
                
            end
            
        end
        
    end
    
    
end

