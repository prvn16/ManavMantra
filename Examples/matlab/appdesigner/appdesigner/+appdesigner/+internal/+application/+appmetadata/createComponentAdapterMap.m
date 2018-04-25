function map = createComponentAdapterMap(metaClasses)
%CREATECOMPONENTADAPTERMAP create a map of component adapters from the
% adapter meta classes

%   Copyright 2015 - 2017 The MathWorks, Inc.

    map = containers.Map;

    % loop over the adapter classes and build the map
    for i = 1:length(metaClasses)
        % get the adapter class name
        adapterClassName = metaClasses{i}.Name;

        % Retrieve the adapter's component type.
        type = eval([adapterClassName '.getComponentType']);

        % add the adapter info to the map.  The key is the
        % component type and value is the adapter class name for that type
        map(type) = adapterClassName;
    end    
end