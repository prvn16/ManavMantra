classdef DesignTimeUIAxesController < ...
        matlab.ui.control.internal.controller.WebUIAxesController & ...
        matlab.ui.internal.DesignTimeGbtParentingController & ...
        appdesservices.internal.interfaces.controller.ServerSidePropertyHandlingController
    
    % DESIGNTIMEUIAXESCONTROLLER - This class contains design time logic
    % specific to matlab.ui.control.UIAxes
    
    % Copyright 2015 - 2017 The MathWorks, Inc.
    
    
    methods
        function obj = DesignTimeUIAxesController( model, parentController, proxyView )
            % CONSTRUCTOR
            
            % Input verification
            narginchk(3, 3);
            
            % Construct the run-time controller first
            obj = obj@matlab.ui.control.internal.controller.WebUIAxesController(model, ...
                parentController, ...
                proxyView);
            
            % Now, construct the client-driven controller
            obj = obj@matlab.ui.internal.DesignTimeGbtParentingController(model, parentController, proxyView);
            
            
            if ~isempty(obj.ProxyView)
                % ProxyView would be empty if it's loading an app
                
                % Update the canvas object in the controller
                model.configureController();
                
                % UIAxes limitations banner: react to initial size
                obj.EventHandlingService.setProperty('InnerPosition', obj.Model.InnerPosition);
                
                % g1347249
                obj.EventHandlingService.setProperty('Position', obj.Model.Position);
            end
        end
        
        function handlePositionUpdate(obj, propertyName, propertyValue)
            % Override handlePositionUpdate from DesignTimeControllerPositionMixin
            switch (propertyName)
                case 'Location'
                    obj.Model.Position(1) = propertyValue(1);
                    obj.Model.Position(2) = propertyValue(2);
                    obj.EventHandlingService.setProperty('Position', obj.Model.Position);
                    obj.EventHandlingService.setProperty('Location', obj.Model.Position(1:2));
                    obj.EventHandlingService.setProperty('OuterLocation', obj.Model.Position(1:2));
                    
                case 'OuterLocation'
                    obj.Model.Position(1) = propertyValue(1);
                    obj.Model.Position(2) = propertyValue(2);
                    obj.EventHandlingService.setProperty('Position', obj.Model.Position);
                    obj.EventHandlingService.setProperty('Location', obj.Model.Position(1:2));
                    obj.EventHandlingService.setProperty('OuterLocation', obj.Model.Position(1:2));
                    
                case 'Size'
                    % @TODO
                    % We should not be clobbering the outer size (Position property)
                    % with the incoming inner size--this may result in the
                    % wrong values
                    obj.Model.Position(3) = propertyValue(1);
                    obj.Model.Position(4) = propertyValue(2);
                    obj.EventHandlingService.setProperty('Position', obj.Model.Position);
                    obj.EventHandlingService.setProperty('Size', obj.Model.Position(3:4));
                    obj.EventHandlingService.setProperty('OuterSize', obj.Model.Position(3:4));
                    
                case 'OuterSize'
                    obj.Model.Position(3) = propertyValue(1);
                    obj.Model.Position(4) = propertyValue(2);
                    obj.EventHandlingService.setProperty('Position', obj.Model.Position);
                    obj.EventHandlingService.setProperty('Size', obj.Model.Position(3:4));
                    obj.EventHandlingService.setProperty('OuterSize', obj.Model.Position(3:4));
                    
            end
            
            % UIAxes limitations banner: react to drag resize
            obj.EventHandlingService.setProperty('InnerPosition', obj.Model.InnerPosition);
        end
    end
    
    methods (Access=protected)
        
        function flushProperties(obj)
            % this method is used to flush all the properties from model to peerNode.
            % the reason for doing this is that there are some dependency properties which will
            % be auto-calculated when some other properties change, and it's hard to find all the dependency
            % properties.
            
            modelProperties = obj.Model;
            modelPropertiesFields = fields(modelProperties);
            for k=1:length(modelPropertiesFields)
                field = modelPropertiesFields{k};
                switch (field)
                    case 'Title'
                        obj.EventHandlingService.setProperty('TitleString', obj.Model.Title.String);
                    case 'XLabel'
                        obj.EventHandlingService.setProperty('XLabelString', obj.Model.XLabel.String);
                    case 'YLabel'
                        obj.EventHandlingService.setProperty('YLabelString', obj.Model.YLabel.String);
                    case 'ZLabel'
                        % do nothing, since we dont expose zlabel in
                        % designtime
                        
                    otherwise
                        if(obj.EventHandlingService.hasProperty(field))
                            obj.EventHandlingService.setProperty(field,  obj.Model.(field));
                        end
                end
            end
        end
        
        function updatePositionWithSizeLocationPropertyChanges(obj, changedPropertiesStruct)
            propertyList = fields(changedPropertiesStruct);
            
            % Update each variable by looking at the changed properties
            for idx = 1:length(propertyList)
                propertyName = propertyList{idx};
                propertyValue = changedPropertiesStruct.(propertyName);
                
                obj.handlePositionUpdate(propertyName, propertyValue);
            end
        end
        
        function handleDesignTimePropertiesChanged(obj, peerNode, valuesStruct)
            handleDesignTimePropertiesChanged@matlab.ui.internal.DesignTimeGBTComponentController(obj, peerNode, valuesStruct);
            obj.flushProperties();
        end
        
        function handleDesignTimePropertyChanged(obj, peerNode, data)
            % handleDesignTimePropertyChanged( obj, peerNode, data )
            % Controller method which handles property updates in design time. For
            % property updates that are common between run time and design time,
            % this method delegates to the corresponding run time controller.
            
            % Handle property updates from the client
            
            updatedPropertyName = data.key;
            updatedPropertyValue = data.newValue;
            
            switch ( updatedPropertyName )
                case {'Location', 'OuterLocation', 'Size', 'OuterSize'}
                    obj.handlePositionUpdate(updatedPropertyName, updatedPropertyValue);
                    
                case 'TitleString'
                    % Update the real model property
                    obj.Model.Title.String = updatedPropertyValue;
                case 'XLabelString'
                    obj.Model.XLabel.String = updatedPropertyValue;
                case 'YLabelString'
                    obj.Model.YLabel.String = updatedPropertyValue;
                case 'YGrid'
                    handleCustomLayoutChanges(obj, updatedPropertyName, updatedPropertyValue);
                case 'Box'
                    handleCustomLayoutChanges(obj, updatedPropertyName, updatedPropertyValue);
                case 'XGrid'
                    handleCustomLayoutChanges(obj, updatedPropertyName, updatedPropertyValue);
                case 'Layout'
                    
                    % The layout is set to custom as a side-effect of
                    % user updating the XGrid/YGrid/Box from the
                    % property inspector. So, do not lose the existing
                    % configuration.
                    if(~strcmpi(updatedPropertyValue, 'custom'))
                        % undo previous layouts
                        obj.revertLayoutToDefault();
                    end
                    
                    if(strcmpi(updatedPropertyValue, 'Layout 1'))
                        % do nothing
                        
                    elseif(strcmpi(updatedPropertyValue, 'Layout 2'))
                        obj.Model.Box = 'on';
                        
                    elseif(strcmpi(updatedPropertyValue, 'Layout 3'))
                        obj.Model.YGrid = 'on';
                        
                    elseif(strcmpi(updatedPropertyValue, 'Layout 4'))
                        obj.Model.YGrid = 'on';
                        obj.Model.XGrid = 'on';
                        obj.Model.Box = 'on';
                    end
                    
                    % With the change - c1407957, all property sheet
                    % edits for UIAxes property change go via the server,
                    % so the layout property needs to be explicitly
                    % updated here
                    obj.EventHandlingService.setProperty('Layout', updatedPropertyValue);
                    
                case {'FontSize', 'XLim', 'YLim', 'ZLim', 'XTick', 'YTick', 'ZTick'}
                    updatedPropertyValue = convertClientNumbertoServerNumber(obj, updatedPropertyValue);
                    obj.Model.(updatedPropertyName) = updatedPropertyValue;
                    
                case {'XLimMode', 'YLimMode', 'ZLimMode', 'XTickMode', 'YTickMode', 'ZTickMode'}
                    obj.Model.(updatedPropertyName) = updatedPropertyValue;
                    
                case  {                        
                        'Color', ...
                        'BackgroundColor', ...
                        'GridColor', ...
                        'MinorGridColor', ...
                        'XColor', ...
                        'YColor', ...
                        'ZColor'...,
                        'AmbientLightColor'...
                        }
                    % Color - related numerics
                    
                    if(isnumeric(updatedPropertyValue))
                        % numeric
                        updatedPropertyValue = convertClientNumbertoServerNumber(obj, updatedPropertyValue);
                        updatedPropertyValue = round(updatedPropertyValue, 4);
                    end
                    % otherwise... assume it is a string such as 'none' and just let the component do the validation at this point
                    obj.Model.(updatedPropertyName) = updatedPropertyValue;
                    
                case {'XTickLabel','YTickLabel','ZTickLabel'}
                    
                    if(~isempty(updatedPropertyValue))
                        % g1353261
                        updatedPropertyValue =  cell(updatedPropertyValue);
                    end
                    obj.Model.(updatedPropertyName) = updatedPropertyValue;
                    
                    
                case 'LineStyleOrder'
                    % Value is a char array representing a cell array
                    % of line style orders
                    %
                    % Ex: '{'- *', '-- s'})
                    %
                    % Needs to be evaled
                    %
                    % g1319014
                    if ischar(updatedPropertyValue) && ...
                            strcmp(updatedPropertyValue(1), '{') && ...
                            strcmp(updatedPropertyValue(end), '}')
                        updatedPropertyValue = eval(updatedPropertyValue);
                    end
                    
                    obj.Model.(updatedPropertyName) = updatedPropertyValue;
                    
                case obj.GenericStringProperties
                    % Update all properties other than FontSmoothing, 
                    % as FontSmoothing is read-only
                    if(~strcmp(updatedPropertyName,'FontSmoothing'))
                    obj.Model.(updatedPropertyName) = updatedPropertyValue;
                    end
                    
                case obj.GenericNumericProperties
                    % If not explicitly handled above, then there are
                    % no side effects in changing the numeric property
                    updatedPropertyValue = convertClientNumbertoServerNumber(obj, updatedPropertyValue);
                    obj.Model.(updatedPropertyName) = updatedPropertyValue;
                    
                otherwise
            end
        end
        
        function handleCustomLayoutChanges(obj,updatedPropertyName,updatedPropertyValue)
            % updatedPropertyValue is initially a string(off,on) but when comes through inspector, is a logical.
            % convert to corresponding off or on when logical
            if(isa(updatedPropertyValue,'logical'))
                if(updatedPropertyValue == 0)
                    booleanUpdatedPropertyValue = 'off';
                elseif(updatedPropertyValue == 1)
                    booleanUpdatedPropertyValue = 'on';
                end
            else
                booleanUpdatedPropertyValue = updatedPropertyValue;
            end
            %explicitly handle changes coming from inspector g1630617
            %and update the view and model
            if(strcmpi(updatedPropertyName,'XGrid'))
                yGrid = obj.Model.YGrid;
                box = obj.Model.Box;
                xGrid = booleanUpdatedPropertyValue;
            elseif(strcmpi(updatedPropertyName,'YGrid'))
                xGrid = obj.Model.XGrid;
                box = obj.Model.Box;
                yGrid = booleanUpdatedPropertyValue;
            else
                yGrid = obj.Model.YGrid;
                xGrid = obj.Model.XGrid;
                box = booleanUpdatedPropertyValue;
            end
            %update view
            % YGrid on, XGrid on, Box on, means box and grid on - Layout 4
            if(strcmpi(yGrid, 'on') && strcmpi(box,'on')&& strcmpi(xGrid,'on'))
                obj.EventHandlingService.setProperty('Layout','Layout 4');
                % YGrid on, XGrid off, Box off - Layout 3
            elseif(strcmpi(yGrid, 'on') && strcmpi(box,'off') && strcmpi(xGrid,'off'))
                obj.EventHandlingService.setProperty('Layout','Layout 3');
                % YGrid off, Box on, XGrid off - Layout 2
            elseif(strcmpi(yGrid, 'off') && strcmpi(box,'on') && strcmpi(xGrid,'off'))
                obj.EventHandlingService.setProperty('Layout','Layout 2');
                % YGrid off, Box off, XGrid off - Layout 1
            elseif(strcmpi(yGrid, 'off') && strcmpi(box,'off') && strcmpi(xGrid,'off'))
                obj.EventHandlingService.setProperty('Layout','Layout 1');
                % Custom layout when some other property is changed
            else
                obj.EventHandlingService.setProperty('Layout','Custom');
            end
            
            %update Model
            obj.Model.(updatedPropertyName) = updatedPropertyValue;
        end
        
        function handleDesignTimeEvent(obj, src, event)
            % Handle changes in the property editor that needs a
            % server side validation
            eventData = event.Data;
            
            
            if(strcmp(eventData.Name, 'PropertyEditorEdited'))
                
                updatedPropertyName = eventData.PropertyName;
                propertySetData.newValue = eventData.PropertyValue;
                propertySetData.key = updatedPropertyName;
                commandId = event.Data.CommandId;
                
                try
                    obj.handleDesignTimePropertyChanged(src, propertySetData);
                    
                    firePropertySetSuccess(obj, updatedPropertyName, commandId);
                    
                    % Check if 'Foo' changed, then update FooMode
                    %
                    % Ex: XLim changed, automatically update XLimMode
                    if(isprop(obj.Model, [updatedPropertyName 'Mode']))
                        obj.EventHandlingService.setProperty([updatedPropertyName 'Mode'], obj.Model.([updatedPropertyName 'Mode']));
                    end
                    
                    % Check if property was like 'FooMode', then update Foo
                    %
                    % Ex: XLimMode changed, so XLim was likely re-calculated
                    if(regexp(updatedPropertyName, 'Mode$'))
                        % Trim off 'Mode' and update just 'Foo'
                        correspondingProperty = updatedPropertyName(1 : end - 4);
                        obj.EventHandlingService.setProperty(correspondingProperty, obj.Model.(correspondingProperty));
                    end
                    
                    obj.flushProperties();
                catch ex
                    firePropertySetFail(obj,  updatedPropertyName, commandId, ex);
                end
            end
            
            % UIAxes limitations banner: react to property changes that
            % could affect inner size
            obj.EventHandlingService.setProperty('InnerPosition', obj.Model.InnerPosition);
            
            % Defer to runtime handleEvent
            obj.handleEvent(src, event);
        end
        
        function handleEvent( obj, src, event )
            % defer to the base class for common event processing
            % Reuse the handlePropertyEvent that is already in the
            % run time controller
            javaMap = appdesservices.internal.peermodel.convertStructToJavaMap( event.Data );
            
            % Add fields to the event data so that the
            % handleEvent gets what it is expecting
            simulatedJavaEventData = struct('getData', javaMap, 'getOriginator', event.getOriginator);
            handleEvent@matlab.ui.control.internal.controller.WebUIAxesController( obj, src, simulatedJavaEventData );
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
            
            % Base class
            viewPvPairs = [viewPvPairs, ...
                getPropertiesForView@matlab.ui.internal.DesignTimeGbtParentingController(obj, propertyNames);
                ];
            
            % Title and Label String
            viewPvPairs = [viewPvPairs, ...
                {'TitleString', obj.Model.Title.String}];
            viewPvPairs = [viewPvPairs, ...
                {'XLabelString', obj.Model.XLabel.String}];
            viewPvPairs = [viewPvPairs, ...
                {'YLabelString', obj.Model.YLabel.String}];
            
            % Layout
            layout = obj.getLayoutValue();
            viewPvPairs = [viewPvPairs, {'Layout', layout}];
            
            % Numeric properties
            props = obj.GenericNumericProperties;
            for idx = 1:length(props)
                name = props{idx};
                value = obj.Model.(name);
                viewPvPairs = [viewPvPairs, {name, value}];
            end
        end
        
        function additionalPropertyNamesForView = getAdditionalPropertyNamesForView(obj)
            % Hook for subclasses to provide a list of property names that
            % needs to be sent to the view for loading in addition to the
            % ones pushed to the view defined by PropertyManagementService
            %
            % Example:
            % 1) Callback function properties
                        
            additionalPropertyNamesForView = {'InnerPosition'; ...
                'TitleString'; 'XLabelString'; 'YLabelString';};
            
            additionalPropertyNamesForView = [additionalPropertyNamesForView; ...
                getAdditionalPropertyNamesForView@matlab.ui.internal.DesignTimeGBTComponentController(obj);...
                ];
            
        end
        
        function excludedPropertyNames = getExcludedPropertyNamesForView(obj)
            % Hook for subclasses to provide a list of property names that
            % needs to be excluded from the properties to sent to the view
            %
            % Examples:
            % - Title
            
            excludedPropertyNames = {'Title'; 'SizeChangedFcn';};
            
            excludedPropertyNames = [excludedPropertyNames; ...
                getExcludedPropertyNamesForView@matlab.ui.internal.DesignTimeGBTComponentController(obj); ...
                ];
            
        end
    end
    
    methods(Access = {...
            ?appdesservices.internal.interfaces.controller.AbstractController,...
            ?appdesservices.internal.interfaces.controller.AbstractControllerMixin,...
            ?matlab.ui.internal.DesignTimeGBTComponentController,...
            })
        function children = getAllChildren(~, ~)
            % UIAxes has children, but does not behave as children
            % component, and they are in one single component
            
            children = [];
        end
    end
    
    methods (Access = private)
        
        function revertLayoutToDefault(obj)
            obj.Model.YGrid = 'off';
            obj.Model.XGrid = 'off';
            obj.Model.Box  = 'off';
        end
        
        function layout = getLayoutValue(obj)
            % 'Layout' is a design-time property but it is not serialized.
            %  So, during a load, the value is computed based on the
            %  value of Grid and Box
            
            layout = '';
            
            if(strcmpi(obj.Model.YGrid, 'off') && ...
                    strcmpi(obj.Model.XGrid, 'off') && ...
                    strcmpi(obj.Model.Box, 'off'))
                layout = 'Layout 1';
            end
            
            if(strcmpi(obj.Model.Box, 'on'))
                layout = 'Layout 2';
            end
            
            if(strcmpi(obj.Model.YGrid, 'on'))
                layout = 'Layout 3';
            end
            
            if(strcmpi(obj.Model.YGrid, 'on') && ...
                    strcmpi(obj.Model.XGrid, 'on') && ...
                    strcmpi(obj.Model.Box, 'on'))
                layout = 'Layout 4';
            end
            
            if(isempty(layout))
                layout = 'Custom';
            end
        end
        
        % Methods that delegate to ServerSidePropertyHandlingController
        %
        % They exist to eliminate some boiler plate CommandId extraction
        % code
        function firePropertySetSuccess(obj, propertyName, commandId)
            propertySetSuccess(obj, propertyName, commandId);
        end
        
        function firePropertySetFail(obj, propertyName, commandId, ex)
            propertySetFail(obj, propertyName, commandId, ex);
        end
    end
    
    
end
