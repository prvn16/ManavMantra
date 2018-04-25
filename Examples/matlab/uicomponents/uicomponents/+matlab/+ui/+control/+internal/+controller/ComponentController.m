classdef (Hidden) ComponentController < ...
        appdesservices.internal.interfaces.controller.AbstractController & ...
        appdesservices.internal.interfaces.controller.ServerSidePropertyHandlingController  & ...
        matlab.ui.control.internal.controller.mixin.PositionableComponentController  & ...
        matlab.ui.control.internal.controller.mixin.HGCommonPropertiesComponentController & ...
        matlab.ui.internal.componentframework.services.optional.ControllerInterface
    
    
    % appdesservices.internal.interfaces.controller.ComponentController
    
    % COMPONENTCONTROLLER Base Class for all HMI Component Controllers.
    %
    % This class provides the following:
    %
    % - creation of all ProxyView's by delegating to the
    %   HmiProxyViewFactoryManager
    %
    % - provides an empty implementation of handleEvent().  Interactive
    %   components should overide this method as needed.
    
    % Copyright 2011-2015 The MathWorks, Inc.
    
    properties
        % List of numeric properties that will be automatically converted
        % when coming from the client, before being set on the model
        % 
        % This property is used by the handler for 'PropertyEditorEdited'
        % to convert event data to numeric values and save controller
        % subclasses from writing boiler plate.
        %
        % Controller subclasses should concatenate any specific properties
        % they want handled onto this property.
        %
        % Its use could be expanded to other places as well, such as
        % responding to any property edit, and not just
        % 'PropertyEditorEdited' events.        
        NumericProperties = {'Position', 'InnerPosition', 'OuterPosition'};
    end
    
    properties(Access = 'protected')
        
        % Cell array of widget events (e.g. mousedragging) for which we
        % want to use an event coalescing mechanism.
        % Note that the client side controller must register the same
        % events
        RegisteredEvents = {};
    end
    
    methods(Access = 'public')
        function obj = ComponentController(varargin)
            obj@appdesservices.internal.interfaces.controller.AbstractController(varargin{:});
        end
        
        function proxyView = createProxyView(obj, propertyPVPairs)
            % CREATEPROXYVIEW(OBJ, PROPERTYPVPAIRS) Creates a Proxy View
            % for this controller.
            %
            % For all HMI components, the HmiProxyViewFactoryManager is
            % used.
            
            % Grab the current factory from the manager
            factoryManager = matlab.ui.control.internal.view.ComponentProxyViewFactoryManager.Instance;
            currentFactory = factoryManager.ProxyViewFactory;
            
            % Get the classname from the Model, which will serve as the
            % type
            className = class(obj.Model);
            
            % Ask the current factory
            proxyView = currentFactory.createProxyView(className, obj.ParentController, propertyPVPairs);
            
        end
        
        function move(obj, newParent)
            % MOVE(OBJ, NEWPARENT) tells the Controller to react to a new
            % parent changing
            %
            % 'newParent' is the model's new parent
            
            % Update this objects parent controller
            obj.ParentController = newParent.getControllerHandle();
            
            % Tell the view to move
            move(obj.ProxyView, newParent.getControllerHandle().ProxyView);
            
        end
        
    end
    
    methods(Access = 'protected')
        
        function handleProxyViewEvent(obj, src, event)
            % Private handler for all events being fired from the Proxy View
            %
            % Event are mapped by names to the following methods
            %
            % 'PropertiesChanged'   -> handlePropertiesChanged
            %
            %  All Others           -> handleEvent
            
            
            if(strcmp(event.Data.Name, 'PropertiesChanged'))
                
                % As part of g1432049 we are changing the runtime
                % interaction workflow so we now ignore propertiesChanged
                % events coming from the client
                
                %g1456338 Tracks the work to remove this section of code
                % Ultimately, the runtime controller will not at all
                % respond to propertiesChanged events at runtime from the
                % client
                
                % Handle Property Change events explicitly
                changedPropertiesStruct = event.Data.Values;
                
                % Filter all but these four position related properties.  
                % When g1456338 is complete, this section of code will be
                % removed completely.
                fieldsToAccept = {'Location',...
                                    'OuterLocation',...
                                    'OuterSize',...
                                    'Size'};
                changedFields = fields(changedPropertiesStruct);
                changedFieldsToRemove = changedFields(~ismember(changedFields, fieldsToAccept));             
                
                filteredStruct = rmfield(changedPropertiesStruct, changedFieldsToRemove);
                
                
                % Set filetered values on the model
                if ~isempty(fields(filteredStruct))
                    handlePropertiesChanged(obj, filteredStruct); 
                end
            else
                % Give subclasses a chance to handle the non-property event
                handleEvent(obj, src, event);
            end

        end
        
        function additionalPropertyNames = getAdditionalPropertyNamesForView(obj)
            % Get the list of additional properties to be sent to the view
            
            additionalPropertyNames = {};
            
            % Position related properties
            additionalPropertyNames = [additionalPropertyNames; ...
                obj.getAdditonalPositionPropertyNamesForView();...
                ];
        end
        
        function excludedPropertyNames = getExcludedPropertyNamesForView(obj)
            % Get the list of properties that need to be excluded from the
            % properties sent to the view
            
            excludedPropertyNames = {};
            
            % Handles to other objects
            excludedPropertyNames = [excludedPropertyNames; {...                
                'Parent'; ...
                'Children'; ...                
                }];

            % HG properties
            excludedPropertyNames = [excludedPropertyNames; ...
                obj.getExcludedHGCommonPropertyNamesForView();...
                ];
            
            % Position related properties
            excludedPropertyNames = [excludedPropertyNames; ...
                obj.getExcludedPositionPropertyNamesForView();...
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
            
            % Size, Location, OuterSize, OuterLocation, AspectRatioLimits, Parent
            viewPvPairs = [viewPvPairs, ...
                getPositionPropertiesForView(obj, propertyNames);
                ];                      
        end
                
        function handleEvent(obj, src, event)
            
            % Allow super classes to handle their events
            wasHandled = handleEvent@matlab.ui.control.internal.controller.mixin.PositionableComponentController(obj, src, event);
            
			if(wasHandled)
				return;
			end
			
            % Handle changes in the property editor that needs a
            % server side validation
            if(strcmp(event.Data.Name, 'PropertyEditorEdited'))
                
                propertyName = event.Data.PropertyName;
                propertyValue = event.Data.PropertyValue;                
                
                if(any(strcmp(obj.NumericProperties, propertyName)))
                    propertyValue = convertClientNumbertoServerNumber(obj, propertyValue);
                end
                
                setModelProperty(obj, propertyName, propertyValue, event);
            end
        end
        
        function handleUserInteraction(obj, clientEventName, callbackInfo)
            % Method to be called by the subclasses when handling a user
            % interaction that results in either:
            % - a user callback executing  (e.g. ButtonPushedFcn)
            % - a property update and a user callback executing (e.g.
            % ValueChangedFcn)
            % - any number greater than 2 of the above (e.g. 'mouseclicked' 
            % results in 2 callbacks)
            %
            % Typically, the subclasses would implement handleEvent, and in
            % the case of a user interaction, call handleUserInteraction.
            %
            % INPUTS:
            %
            %  - clientEventName:  event name of the client side event
            %                       that this is a response to
            % 
            %  - as many cells as the number of callbacks to execute.
            %  Minimum is 1. 
            %  See executeUserCallback for the formatting of each cell.
            %
            % Example: 
            %
            % obj.handleUserInteraction(...
            %       'mousedragging', ...
            %       {'ValueChanging', eventData}, ...
            %       {'ValueChanged', eventData, 'Value', newValue}, ...
            %       );          
            
            assert(nargin == 3);
            
            % Callback info is expected to be a cell array with data for the
            % callback execution.  HandleUserInteraction should be used to
            % trigger one and exactly one MATLAB callback.
            % If multiple callbacks are required, initialize multiple
            % callback events from the client.g1465034
            assert(iscell(callbackInfo))
                
             
                obj.executeUserCallback(callbackInfo{:});

            
            % After all matlab events for this client side event have been
            % emitted and callbacks processed, send an event to the client
            % if the event is registered to use an event coalescing
            % mechanism. 
            if(isvalid(obj) && ismember(clientEventName, obj.RegisteredEvents) && ...
                    ~isempty(obj.ProxyView) && isvalid(obj.ProxyView))
                % Need to check if obj and ProxyView are valid or not because
                % the user's callback could delete the app or the compnoent
                % see g1336677
                obj.ProxyView.sendEventToClient('flush',...
                    { ...
                    'WidgetEvent', clientEventName, ...                    
                    });
            end
            
        end
        
        function executeUserCallback(obj, matlabEventName, matlabEventData, propertyName, propertyValue)
            % Execute user callbacks associated with 'matlabEventName'.
            % If a property-value pair is also provided, the property will
            % be updated before the callbacks are executed.
            % 
            % INPUTS:
            %
            %  - MatlabEventName:  string representing the event that the component
            %                model should emit as a result of the user interaction
            %  - MatlabEventData:  eventdata associated with eventName
            %
            % Example: obj.executeUserCallback('ButtonPushed', 'ButtonPushed', eventData);          
            %
            % Optional INPUTS:
            %
            %  - propertyName:    name of the property to be modified as
            %                     a result of the user interaction if any
            %  - propertyValue:   value to update the property to
            %
            % Example: obj.executeUserCallback('ValueChanged', eventData, 'Value', newValue);                

                        
            assert(nargin == 3 || nargin == 5);
            
            if(nargin == 3)
                % There is no property to update, just emit the event
                
                % Have the model emit the event
                % The event handling system will execute the callbacks
                % associated with this event.
                notify(obj.Model, matlabEventName, matlabEventData);
                
            else            
                % propertyName and propertyValue were passed in as inputs
                % The property needs to be updated before sending the event
                
                oldValue = obj.Model.(propertyName);
                
                % Check that the property value has indeed changed
                if(isequal(oldValue,propertyValue))
                    % The value has not changed, do not emit event.
                    % This check is a catch all for instances where the
                    % view does send an event even when the value didn't 
                    % really change. 
                    return;
                end
                
                % Update the property value
                obj.Model.(propertyName) = propertyValue;
                
                % Force the view to process the value update before
                % emitting the event.
                % If the property is revered to its old value in a callback
                % (its own or from another component),
                % the visual might not update because of the peer node
                % coalescing events from property sets.
                % Ensure that the visual will react to a potential
                % reversion by forcing the view to process the current
                % value.
                %
                % We don't need to specify any property names in
                % 'refreshProperties' because simply sending an event
                % flushes the propertiesSet event queue. If we explicitly
                % passed in the propertyName, the view would refresh
                % twice in the case of the reversion from the callback of
                % another component.
                %
                % see g1124873 and g1218934
                obj.ProxyView.refreshProperties({});
                
                % Have the model emit the event
                % The event handling system will execute the callbacks
                % associated with this event.
                notify(obj.Model, matlabEventName, matlabEventData);
               
            end
        end
        
        function handlePropertiesChanged(obj, changedPropertiesStruct)
            % Handles properties changed from client
            
            % Check for properties with a corresponding 'Mode' property
            %
            % This check is to explicitly handle the case when the client
            % is sending a property change struct like:
            %
            % XLim      : [0 100]
            % XLimMode  : 'auto'
            % ...
            %
            % or
            %
            % Limits    : [0, 100]
            % MajorTicks: 0:20:100
            % ...
            %
            % In the case where the mode is 'auto', the property values are
            % for the sibling property (XLim) are there just beacuse the
            % view needs them, and we do not want to overwrite what the
            % Model currently has.
            %
            % In the case of dependent properties like Limits and
            % MajorTicks, the mode is in 'auto' but might not have been
            % passed in changedPropertiesStruct if the mode was already
            % 'auto' (it is filtered out by peer node layer if unchanged).
            % Althought the mode is not passed in, we need to check if the
            % mode is 'auto' and if so, not explicitely set it on the model
            % (to avoid flipping the mode to 'manual' (see g1044814)
            %
            % Therefore, explicitly look for properties with a 'Mode' property.
            % If the mode property is 'auto', then exclude the sibling from
            % being set and let 'auto' take over
            includeHiddenProperty = false;
            priorModePropertyOnModel = true;
            changedPropertiesStruct = obj.handleChangedPropertiesWithMode(obj.Model, changedPropertiesStruct, includeHiddenProperty, priorModePropertyOnModel);            
            
            % 'BeingDeleted' is a readonly property that should not be set on the model.
            % AbstractComponent owns adding 'BeingDeleted' which is the
            % highest UIComponent model class (not part of appdesservices)
            % ComponentController will remove the property because it is
            % the highest UIComponent controller (not part of
            % appdesservices
            
            readOnlyProperty = 'BeingDeleted';
            if(isfield(changedPropertiesStruct, readOnlyProperty))
                changedPropertiesStruct = rmfield(changedPropertiesStruct, readOnlyProperty);
            end    
            % Allow super classes to handle properties changed
            unHandledProperties = handlePropertiesChanged@matlab.ui.control.internal.controller.mixin.PositionableComponentController(obj, changedPropertiesStruct);            
            handlePropertiesChanged@appdesservices.internal.interfaces.controller.AbstractController(obj, unHandledProperties);
        end
        
        function registerEvents(obj, eventList)
            % Allows controllers to specify the events for which an event
            % needs to be sent to the client when the callbacks are done
            % executing
            
            if(ischar(eventList))
                % Convert into a cell of one element
                eventList = {eventList};
            end
            
            for k=1:length(eventList)
                % Only add the event if it is not already registered
                if(~ismember(eventList{k}, obj.RegisteredEvents))
                    obj.RegisteredEvents{end+1} = eventList{k};
                end
            end
    end
    end
    
    methods(Access = {...
            ?appdesservices.internal.interfaces.controller.AbstractControllerMixin, ...
            ?appdesservices.internal.interfaces.controller.AbstractController
            })
        
        function setModelProperty(obj, propertyName, propertyValue, event)
            % Convience function used to set a model property.
            %
            % Passes through to parent class and consolodates the
            % extraction of the command ID, model
            
            commandId = event.Data.CommandId;
             model = obj.Model;
                
             setServerSideProperty(obj, model, propertyName, propertyValue, commandId)
        end
        
    end
end
