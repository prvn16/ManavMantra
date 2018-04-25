classdef (Hidden) NumberFieldController < ...
        matlab.ui.control.internal.controller.ComponentController
    
    % NUMBERFIELDCONTROLLER class is the controller class for
    % matlab.ui.control.NumberField object.
    
    % Copyright 2011-2017 The MathWorks, Inc.
    
    methods
        function obj = NumberFieldController(varargin)
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
            
            % Numeric Display needs to be formatted
            if(any(ismember({'ValueDisplayFormat', 'Value'}, propertyNames)))
                viewPvPairs = [viewPvPairs, ...
                    {'DisplayText', obj.getFormattedDisplayText(obj.Model.ValueDisplayFormat, obj.Model.Value)} ...
                    ];
            end
            
            if(any(ismember({'Limits'}, propertyNames)))
                limitsValue = obj.Model.Limits;
                viewPvPairs = [viewPvPairs, ...
                    {'Limits', limitsValue, ...
                    'LowerLimit', limitsValue(1), ...
                    'UpperLimit', limitsValue(2) ...
                    }];
            end            
        end
        
        
        function changedPropertiesStruct = handlePropertiesChanged(obj, changedPropertiesStruct)
            % Handle specific property sets
            
            % Because the number field has several interdependent
            % properties, they need to be handled in a specific order
            
            % - Limits
            % - Value
            if(any(strcmp('LowerLimitInclusive', fieldnames(changedPropertiesStruct))))
                
                newValue = changedPropertiesStruct.LowerLimitInclusive;
                
                % Apply to the model
                obj.Model.LowerLimitInclusive = newValue;
                
                % Remove the field from the struct since it has
                % been handled already
                changedPropertiesStruct = rmfield(changedPropertiesStruct, 'LowerLimitInclusive');
            end
            
            if(any(strcmp('UpperLimitInclusive', fieldnames(changedPropertiesStruct))))
                
                newValue = changedPropertiesStruct.UpperLimitInclusive;
                
                % Apply to the model
                obj.Model.UpperLimitInclusive = newValue;
                
                % Remove the field from the struct since it has
                % been handled already
                changedPropertiesStruct = rmfield(changedPropertiesStruct, 'UpperLimitInclusive');
            end
            
            
            if(any(strcmp('Limits', fieldnames(changedPropertiesStruct))))
                
                newLimits = convertClientNumbertoServerNumber(obj, changedPropertiesStruct.Limits);
                
                % Apply to the model
                obj.Model.Limits = newLimits;
                
                % Remove the field from the struct since it has
                % been handled already
                changedPropertiesStruct = rmfield(changedPropertiesStruct, 'Limits');
            end
            
            
            if(any(strcmp('LowerLimit', fieldnames(changedPropertiesStruct))))
                newLowerLimit = convertClientNumbertoServerNumber(obj, changedPropertiesStruct.LowerLimit);
                
                % Apply to the model
                obj.Model.Limits(1) = newLowerLimit;
                
                % Remove the field from the struct since it has
                % been handled already
                changedPropertiesStruct = rmfield(changedPropertiesStruct, 'LowerLimit');
            end
            
            if(any(strcmp('UpperLimit', fieldnames(changedPropertiesStruct))))
                newUpperLimit = convertClientNumbertoServerNumber(obj, changedPropertiesStruct.UpperLimit);
                
                % Apply to the model
                obj.Model.Limits(2) = newUpperLimit;
                
                % Remove the field from the struct since it has
                % been handled already
                changedPropertiesStruct = rmfield(changedPropertiesStruct, 'UpperLimit');
            end
            
            if(any(strcmp('Value', fieldnames(changedPropertiesStruct))))
                newValue = convertClientNumbertoServerNumber(obj, changedPropertiesStruct.Value);
                
                % Apply to the model
                obj.Model.Value = newValue;
                
                % Remove the field from the struct since it has
                % been handled already
                changedPropertiesStruct = rmfield(changedPropertiesStruct, 'Value');
            end
            
            % Call the superclasses for unhandled properties
            handlePropertiesChanged@matlab.ui.control.internal.controller.ComponentController(obj, changedPropertiesStruct);
        end
        
        function handleEvent(obj, src, event)
            
            if(strcmp(event.Data.Name, 'PropertyEditorEdited'))
                % Handle changes in the property editor that needs a
                % server side validation
                
                propertyName = event.Data.PropertyName;
                propertyValue = event.Data.PropertyValue;
                
                % Handle LowerLimit, UpperLimit, and Value by converting from
                % string to double representations
                if(any(strcmp(propertyName, {'LowerLimit', 'UpperLimit', 'Value', 'Limits'})))
                    
                    if(strcmp(propertyName, 'Limits'))
                        
                        % Convert string Limits to MATLAB double limits
                        
                        propertyValue = convertClientNumbertoServerNumber(obj, propertyValue);
                        
                    elseif(strcmp(propertyName, 'LowerLimit'))
                        
                        propertyName = 'Limits';
                        
                        if(isempty(propertyValue))
                            % Coerce '' to -Inf
                            propertyValue = [-Inf obj.Model.Limits(2)];
                        else
                            propertyValue = [convertClientNumbertoServerNumber(obj, propertyValue) obj.Model.Limits(2)];
                        end
                        
                    elseif(strcmp(propertyName, 'UpperLimit'))
                        propertyName = 'Limits';
                        
                        if(isempty(propertyValue))
                            % Coerce '' to -Inf
                            propertyValue = [obj.Model.Limits(1) Inf];
                        else
                            propertyValue = [obj.Model.Limits(1) convertClientNumbertoServerNumber(obj, propertyValue)];
                        end
                    else
                        % Coerce values like '123' to 123
                        propertyValue = convertClientNumbertoServerNumber(obj, propertyValue);
                    end
                    
                    % Update the event data in line
                    setModelProperty(obj, ...
                        propertyName, ...
                        propertyValue, ...
                        event ...
                        );
                    
                    
                    refreshValueRelatedProperties(obj)
                    
                else
                    % Defer to super otherwise
                    %
                    % The property edit does not need to be specially
                    % handled
                    handleEvent@matlab.ui.control.internal.controller.ComponentController(obj, src, event);
                end
                
                % stop handling other events
                return;
                
            elseif(strcmp(event.Data.Name, 'ValueChanged'))
                % Handles when the user changes the numeric value in the ui
                
                % Store the previous value
                previousValue = obj.Model.Value;
                
                newValue = obj.convertClientNumbertoServerNumber(event.Data.Value);
                
                % Create event data
                eventData = matlab.ui.eventdata.ValueChangedData(newValue, previousValue);
                
                % Update the model and emit 'ValueChanged' which in turn will
                % trigger the user callback
                obj.handleUserInteraction('ValueChanged', {'ValueChanged', eventData, 'PrivateValue', newValue});
                
            end
            
            % Defer to super
            handleEvent@matlab.ui.control.internal.controller.ComponentController(obj, src, event);
        end
    end
    
    methods(Access = 'protected')
        function refreshValueRelatedProperties(obj)
            
            % This handles the case where:
            %   - RoundFractionalValues == 'on'
            %   - and the user enters a value which will be rounded to the
            %   same value (from the component or its property editor)
            %
            % Example:
            %  'Value' = 1 on the server and view
            %  The user enters the new value 1.2 from the view
            %  The value 1.2 is sent to the server which will round it to
            %  1. The event PropertiesSet is triggered but will not be
            %  forwarded to the view because the peer node's value for
            %  the property 'Value' is already 1 on the view side.
            %
            %  However, the view needs to revert the user entered value of
            %  1.2 to 1.
            %
            % Example:
            %  'LowerLimit' = -Inf on the server and view
            %  The user enters the '' in the view
            %  The value '' is sent to the server, which this controller
            %  converts to -Inf.
            %
            %  Again, the property set is not triggered because the value
            %  is -Inf on both the client and server.
            %
            % In such cases, we force the event by sending a custom event
            % of type 'peerEvent'
            
            if(~isempty(obj.ProxyView))
                
                % PeerNode value for property 'Value'
                proxyviewValue = obj.ProxyView.getProperties().Value;
                
                % Check whether we are in the Value case described above
                if(strcmp(obj.Model.RoundFractionalValues, 'on') && ...
                        obj.Model.Value == proxyviewValue)
                    
                    % Send the custom event
                    obj.ProxyView.refreshProperties({ ...
                        'Value', obj.Model.Value, ...
                        'DisplayText', obj.getFormattedDisplayText(obj.Model.ValueDisplayFormat, obj.Model.Value)
                        });
                end
                
                % Refresh -Inf case
                if(obj.Model.Limits(1) == 0)
                    obj.ProxyView.refreshProperties({ ...
                        'Limits', obj.Model.Limits, ...
                        });
                end
                
                % Refresh Inf case
                if(obj.Model.Limits(2) == Inf)
                    obj.ProxyView.refreshProperties({ ...
                        'Limits', obj.Model.Limits, ...
                        });
                end
            end
            
        end
        
    end
    methods (Static)
        function description = getFormattedDisplayText(valueDisplayFormat, value)
            
            if(ischar(value))
                % Ex: 'Inf'
                % Convert char version of limit -> number
                value = str2double(value);
            end
            
            description = sprintf(valueDisplayFormat, value);
            
            % do not show white space in the visual
            description = strtrim(description);
        end
        
        
    end
    
end


