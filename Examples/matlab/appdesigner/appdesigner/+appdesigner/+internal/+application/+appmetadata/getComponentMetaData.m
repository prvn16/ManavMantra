function componentMetadata = getComponentMetaData(componentAdapterMap)
    % GETCOMPONENTMETADATA retrieve the component initialization data required by the
    % client

    % create an empty component metadata struct

    %   Copyright 2015 The MathWorks, Inc.

    componentMetadata = struct.empty;

    % retrieve the list of adapters from the map
    adapterFileNames = values(componentAdapterMap);

    % iterate over the adapter file names and create a structure of component
    % data
    for j=1:length(adapterFileNames)
        adapterFileName = adapterFileNames{j};
        adapterInstance = eval(adapterFileName);

        % create a structure holding component metadata for each
        % component type.  The metadata is the component default
        % values retrieved via the component adapter
        componentMetadata(end+1).Type = adapterInstance.getComponentType();
        componentMetadata(end).DefaultValues =...
            adapterInstance.getComponentDesignTimeDefaults();

        componentMetadata(end).JavaScriptAdapter = adapterInstance.getJavaScriptAdapter();
        componentMetadata(end).MATLABAdapter = adapterFileName;
    end
end

