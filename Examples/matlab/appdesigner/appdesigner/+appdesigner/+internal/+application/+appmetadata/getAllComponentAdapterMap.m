function adapterMap = getAllComponentAdapterMap()
%GETALLCOMPONENTADAPTERMAP get a map of all component adapters registered
% in the App Designer Design Environment, including components still under
% development

% find all the registered component adapter classes that are in
% the 'appdesigner.internal.componentadapter' package and extend
% from 'appdesigner.internal.componentadapterapi.ComponentRegistration'.
% The list returned contains metaclasses of the adapters

%   Copyright 2017 The MathWorks, Inc.

    % Product component adatper
    prodComponentAdapterMap = appdesigner.internal.application.appmetadata.getProductionComponentAdapterMap();
    % Make a copy of it to avoid polluting product component adapter
    % map
    adapterMap = containers.Map;
    componentAdapterKeys = keys(prodComponentAdapterMap);
    for keyIndex = 1:numel(componentAdapterKeys)
        adapterType = componentAdapterKeys{keyIndex};            
        adapterMap(adapterType) = prodComponentAdapterMap(adapterType);            
    end

    % Adapter of components under development 
    devComponentMetaClasses = appdesigner.internal.application.appmetadata.findDevComponentAdapter();
    devComponentAdapterMap = appdesigner.internal.application.appmetadata.createComponentAdapterMap(devComponentMetaClasses);
    devComponentAdapterKeys = keys(devComponentAdapterMap);

    % Merge the development component adapters
    for keyIndex = 1:numel(devComponentAdapterKeys)
        adapterType = devComponentAdapterKeys{keyIndex};            
        adapterMap(adapterType) = devComponentAdapterMap(adapterType);            
    end
end