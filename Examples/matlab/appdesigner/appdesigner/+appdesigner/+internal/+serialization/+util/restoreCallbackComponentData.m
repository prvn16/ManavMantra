function callbacks = restoreCallbackComponentData(UIFigure,callbacks)
    % Now that serialization Version 2 no longer serializes the ComponentData for each callback,
    % this is a  function to restore the component data when needed
    % (codeName,callbackPropertyname,componentType):
    %  1.  When loading an app of the new serialization format to recreate
    %       the component data info going to the client
    % 2.  When converting a Serialization Version 2 app
    %      to version 1
    
    % Copyright 2017 The MathWorks, Inc.
    
    % add a ComponentData Field to make the returned callbacks homogenous
    if (numel(callbacks) > 0 && all(isfield(callbacks, {'Name', 'Code'})))
        
        if (~isfield(callbacks, 'ComponentData'))
            [callbacks(:).ComponentData] = deal(struct( ...
                'CodeName', {}, ...
                'CallbackPropertyName', {}, ...
                'ComponentType', {}));
        end
        
        componentList = findall(UIFigure, '-property', 'DesignTimeProperties');
        for i = 1:numel(componentList)
            component = componentList(i);
            componentType = class(component);
            callbackPropertyNames = getComponentCallbackPropertyNames(componentType);
            
            for callbackIx = 1:numel(callbackPropertyNames)
                callbackPropertyName = callbackPropertyNames{callbackIx};
                callbackName = component.(callbackPropertyName);
                if ~isempty(callbackName)
                    % loop over the callbacks
                    for j = 1:numel(callbacks)
                        callback = callbacks(j);
                        name = callback.Name;
                        
                        if strcmp(callbackName, name)
                            x = numel(callbacks(j).ComponentData) + 1;
                            callbacks(j).ComponentData(x).CodeName = component.DesignTimeProperties.CodeName;
                            callbacks(j).ComponentData(x).CallbackPropertyName = callbackPropertyName;
                            callbacks(j).ComponentData(x).ComponentType = componentType;
                        end
                    end
                end
            end
        end
    end
end

function callbackPropertyNames = getComponentCallbackPropertyNames(componentType)
    
    persistent componentPropertyNameMap;
    
    if isempty(componentPropertyNameMap)
        componentPropertyNameMap = containers.Map();
    end
    
    if componentPropertyNameMap.isKey(componentType)
        callbackPropertyNames = componentPropertyNameMap(componentType);
    else
        metaClass = meta.class.fromName(componentType);
        propertyList = metaClass.PropertyList;
        propertyNumber = numel(propertyList);
        callbackPropertyNames = cell(1, propertyNumber);
        
        if ~isempty(propertyList)
            callbackPropertyIdx = 1;
            % Get App Designer supported properties
            % Find the callback property names, which is a type of
            % 'matlab.graphics.datatype.Callback', and with
            % SetAccess be 'public', and not 'Hidden'
            for i = 1:numel(propertyList)
                property = propertyList(i);
                if strcmp(property.Type.Name, 'matlab.graphics.datatype.Callback') && ...
                        any(strcmp(property.SetAccess, 'public')) && ...
                        ~property.Hidden
                    callbackPropertyNames{callbackPropertyIdx} = property.Name;
                    callbackPropertyIdx = callbackPropertyIdx + 1;
                end
            end
            % Remove empty content elements
            callbackPropertyNames(callbackPropertyIdx:propertyNumber) = [];
        end
        
        componentPropertyNameMap(componentType) = callbackPropertyNames;
    end
end
