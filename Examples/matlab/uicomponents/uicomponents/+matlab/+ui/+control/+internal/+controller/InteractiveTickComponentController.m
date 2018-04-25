classdef (Hidden) InteractiveTickComponentController < matlab.ui.control.internal.controller.TickComponentController
    % Controller for AbstractInteractiveTickComponent
    
    % Copyright 2011-2013 The MathWorks, Inc.
    
    methods
        function obj = InteractiveTickComponentController(varargin)
            obj@matlab.ui.control.internal.controller.TickComponentController(varargin{:});
            
            % Register the events for which we want to use the event
            % coalescing mechanism
            % Note: the same events must be registered on the client side
            % controller
            obj.registerEvents('mousedragging');
        end
    end
    methods(Access = 'protected')
        
        function changedPropertiesStruct = handlePropertiesChanged(obj, changedPropertiesStruct)
            % Handle specific property sets
            
            % Because 'Value' must fall into Limits, need to explicitly
            % handle first
            if(any(strcmp('Limits', fieldnames(changedPropertiesStruct))))
                
                newLimits = convertClientNumbertoServerNumber(obj, changedPropertiesStruct.Limits);
                
                % Apply to the model
                obj.Model.Limits = newLimits;
                
                % Remove the field from the struct since it has
                % been handled already
                changedPropertiesStruct = rmfield(changedPropertiesStruct, 'Limits');
            end
            
            % Call the superclasses for unhandled properties
            handlePropertiesChanged@matlab.ui.control.internal.controller.TickComponentController(obj, changedPropertiesStruct);
        end
        
        function handleEvent(obj, src, event)
            % HANDLEEVENT(OBJ, ~, EVENT) this method is invoked each time
            % user moves the needle / thumb of the component.
            
            handleEvent@matlab.ui.control.internal.controller.TickComponentController(obj, src, event);
            
            switch(lower(event.Data.Name))
                
                case {'mousedragging' 'mousedragreleased', 'mouseclicked'}
                    % The three type of mouse moving events are:
                    %
                    % 'mousedragging'
                    % - continuous drag events, as the user is dragging with
                    %   the mouse down
                    %
                    % 'mousedragreleased'
                    %  - the "mouse up" after a drag finishes
                    %
                    % 'mouseclicked'
                    % - a single click and release on the component's body
                    %
                    % 'mouseclickrelease'
                    % - - the "mouse up" before a click finishes
                    
                    % Store the previous value
                    previousValue = obj.Model.Value;
                    
                    newValue = event.Data.Value;
                    
                    if(strcmpi(event.Data.Name, 'mouseclicked'))
                        % User clicked on some area on the dial
                        % Emit both 'ValueChanged' and 'ValueChanging' events
                        
                        % Create event data for 'ValueChanged'
                        valueChangedEventData = matlab.ui.eventdata.ValueChangedData(newValue, previousValue);
                        
                        % Emit 'ValueChanging' which will in turn trigger
                        % ValueChangingFcn and 'ValueChanged' which will in
                        % turn trigger ValueChangingFcn
                        obj.handleUserInteraction('mouseclicked', ...
                            {'ValueChanged', valueChangedEventData, 'PrivateValue', newValue});
                        
                    elseif(strcmpi(event.Data.Name, 'mousedragreleased'))
                        % the user action is done. so emit the
                        % 'ValueChanged' event
                        
                        % Create event data for 'ValueChanged'
                        valueChangedEventData = matlab.ui.eventdata.ValueChangedData(newValue, previousValue);
                        
                        % Update the model and emit 'ValueChanged' which in turn will
                        % trigger the user callback
                        obj.handleUserInteraction('mousedragreleased', {'ValueChanged', valueChangedEventData, 'PrivateValue', newValue});
                        
                    else
                        % 'mousedragging'
                        %
                        % the users is still dragging the mouse. so don't
                        % change the value of the component, just emit the
                        % 'ValueChanging' event
                        
                        % Create event data for 'ValueChanging'
                        valueChangingEventData = matlab.ui.eventdata.ValueChangingData(newValue);
                        
                        % Emit 'ValueChanging' which will in trun trigger
                        % ValueChangingFcn
                        obj.handleUserInteraction('mousedragging', {'ValueChanging', valueChangingEventData});
                    end
            end
            
        end
        
    end
    
end

