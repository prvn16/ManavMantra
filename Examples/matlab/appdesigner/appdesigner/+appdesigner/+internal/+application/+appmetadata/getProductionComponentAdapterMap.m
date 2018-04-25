function map = getProductionComponentAdapterMap()
%GETPRODUCTIONCOMPONENTADAPTERMAP get a map of component adapters registered
% in the App Designer Design Environment

% find the registered component adapter classes that are in
% the 'appdesigner.internal.componentadapter' package and extend
% from 'appdesigner.internal.componentadapterapi.ComponentRegistration',
% but not extend from 'appdesigner.internal.componentadapterapi.DevComponentAdapter'.
% The list returned contains metaclasses of the adapters

%   Copyright 2017 The MathWorks, Inc.

% cache the created component adapters and component types since they will
% not change during the lifetime of App Designer
persistent adapterMap;

if isempty(adapterMap)
    % meta classes for the components that are in product
    allComponentMetaClasses = internal.findSubClasses( ...
        'appdesigner.internal.componentadapter', ...
        'appdesigner.internal.componentadapterapi.ComponentRegistration', ...
        true);
    
    % Filter out the following component adapter meta classes
    devComponentMetaClasses = appdesigner.internal.application.appmetadata.findDevComponentAdapter();    
    metaClassKeepIndex = true(1, numel(allComponentMetaClasses));
    for k = numel(allComponentMetaClasses):-1:1
        foundIndex = cellfun(@(metaClass)eq(metaClass, allComponentMetaClasses{k}), ...
            devComponentMetaClasses);
        if any(foundIndex)
            metaClassKeepIndex(k) = false;
        end
    end
    
    metaClasses = allComponentMetaClasses(metaClassKeepIndex);
    
    adapterMap = appdesigner.internal.application.appmetadata.createComponentAdapterMap(metaClasses);
end

map = adapterMap;
end