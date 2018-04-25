function docContent = getComponentPropertyDocumentation(componentTypes)
    %GETCOMPONENTPROPERTYDOCUMENTATION Retrieves component property
    %documentation from the Doc Center
    
    % Copyright 2016 - 2017 The MathWorks, Inc.
    
    import appdesigner.internal.application.retrieveDocCenterPropertiesContent
    
    appDesignEvironment = appdesigner.internal.application.getAppDesignEnvironment();
    adapterMap = appDesignEvironment.getComponentAdapterMap();
    adapterMapKeys = adapterMap.keys();
    
    if(nargin > 0)
        if(ischar(componentTypes))
            % convert to a cell array to handle multiple queries
            componentTypes = {componentTypes};
        end
    else
        % if no arguments are provided use all components to get property
        % documentation
        componentTypes = adapterMapKeys;
    end
    
    % create an empty struct to store Doc Center data
    docContent(length(componentTypes)) = struct('Type', '', 'Properties', []);
    
    % search Doc Center for App Designer component property documentation
    appdTypes = cellfun(@(x)strcat(x, 'appd'), componentTypes, 'UniformOutput', false);
    foundContent = retrieveDocCenterPropertiesContent(appdTypes);
    
    for i = 1:length(componentTypes)
        if(isKey(adapterMap, componentTypes{i}))
            docContent(i).Type = componentTypes{i};
            props = foundContent(i).Properties;
            if (isempty(props))
                % retrieve the non-App Designer Specific help page
                content = retrieveDocCenterPropertiesContent(componentTypes{i});
                props = content.Properties;
            end
            docContent(i).Properties = props;
        end
    end
end
