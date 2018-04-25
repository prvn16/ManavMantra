classdef (Hidden) EditFieldController < matlab.ui.control.internal.controller.ComponentController
    % EditFieldController class is the controller class for the EditField
    
    % Copyright 2016 The MathWorks, Inc.
    
    methods
        function obj = EditFieldController(varargin)                      
            obj@matlab.ui.control.internal.controller.ComponentController(varargin{:});
            
            % Register the events for which we want to use the event
            % coalescing mechanism
            % Note: the same events must be registered on the client side
            % controller
            obj.registerEvents('ValueChanging');
        end
    end    
    
    methods(Access = 'protected')
        
        function handleEvent(obj, src, event)
            % Allow super classes to handle their events
            handleEvent@matlab.ui.control.internal.controller.ComponentController(obj, src, event);
            
            if(strcmp(event.Data.Name, 'ValueChanged'))
                % Handles when the user commits new text in the ui
                % Emit both 'ValueChanged' and 'ValueChanging' events
                
                % Get the previous value
                previousValue = obj.Model.Value;
                
                % Get the new value
                newValue = event.Data.Value;
                
                % Create event data for 'ValueChanged'
                valueChangedEventData = matlab.ui.eventdata.ValueChangedData(newValue, previousValue);
                
                % Update the model and emit both 'ValueChanged' and
                % 'ValueChanging' which will in turn trigger the callbacks
                obj.handleUserInteraction('ValueChanged', ...
                    {'ValueChanged', valueChangedEventData, 'PrivateValue', newValue});                
            
            elseif (strcmp(event.Data.Name, 'ValueChanging'))
                % Handles when the user is editing the edit field
                
                newValue = event.Data.Value;
                
                % Create event data for 'ValueChanging'
                valueChangingEventData = matlab.ui.eventdata.ValueChangingData(newValue);

                % Emit 'ValueChanging' which will in trun trigger
                % ValueChangingFcn
                obj.handleUserInteraction('ValueChanging', {'ValueChanging', valueChangingEventData});

            end
        end
    end
    
    
end