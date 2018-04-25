classdef InteractionCatalog < handle
    % This class is undocumented and may change in a future release.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        MockObjectSimpleClassName (1,1) string;
        VisibleMethodNames (1,:) string;
        VisiblePropertyNames (1,:) string;
    end
    
    properties (SetAccess=immutable, GetAccess=private)
        MethodCallSpecification matlab.mock.internal.List;
        MethodCallRecord matlab.mock.internal.List;
        PropertyGetSpecification matlab.mock.internal.List;
        PropertyGetRecord matlab.mock.internal.List;
        PropertySetSpecification matlab.mock.internal.List;
        PropertySetRecord matlab.mock.internal.List;
    end
    
    properties (Access=private)
        Count (1,1) uint64;
    end
    
    methods
        function catalog = InteractionCatalog(className, visibleMethodNames, visiblePropertyNames)
            import matlab.mock.internal.List;
            
            if nargin > 0
                catalog.MockObjectSimpleClassName = className;
                if nargin > 1
                    catalog.VisibleMethodNames = visibleMethodNames;
                    if nargin > 2
                        catalog.VisiblePropertyNames = visiblePropertyNames;
                    end
                end
            end
            
            catalog.MethodCallSpecification = List;
            catalog.MethodCallRecord = List;
            catalog.PropertyGetSpecification = List;
            catalog.PropertyGetRecord = List;
            catalog.PropertySetSpecification = List;
            catalog.PropertySetRecord = List;
        end
        
        function addMethodSpecification(catalog, specification)
            catalog.MethodCallSpecification.prepend(specification);
        end
        
        function entry = lookupMethodSpecification(catalog, behavior)
            entry = lookup(behavior, catalog.MethodCallSpecification);
        end
        
        function entry = addMethodEntry(catalog, value)
            catalog.incrementInteractionCount;
            entry = catalog.MethodCallRecord.append(value, catalog.Count);
        end
        
        function count = getMethodCallCount(catalog, behavior)
            count = getCount(behavior, catalog.MethodCallRecord);
        end
        
        function records = getAllMethodCalls(catalog, name)
            records = getAll(catalog.MethodCallRecord, name);
        end
        
        function addPropertyGetSpecification(catalog, specification)
            catalog.PropertyGetSpecification.prepend(specification);
        end
        
        function entry = lookupPropertyGetSpecification(catalog, behavior)
            entry = lookup(behavior, catalog.PropertyGetSpecification);
        end
        
        function entry = addPropertyGetEntry(catalog, value)
            catalog.incrementInteractionCount;
            entry = catalog.PropertyGetRecord.append(value, catalog.Count);
        end
        
        function count = getPropertyGetCount(catalog, behavior)
            count = getCount(behavior, catalog.PropertyGetRecord);
        end
        
        function addPropertySetSpecification(catalog, specification)
            catalog.PropertySetSpecification.prepend(specification);
        end
        
        function entry = lookupPropertySetSpecification(catalog, behavior)
            entry = lookup(behavior, catalog.PropertySetSpecification);
        end
        
        function entry = addPropertySetEntry(catalog, value)
            catalog.incrementInteractionCount;
            entry = catalog.PropertySetRecord.append(value, catalog.Count);
        end
        
        function count = getPropertySetCount(catalog, behavior)
            count = getCount(behavior, catalog.PropertySetRecord);
        end
        
        function records = getAllPropertySets(catalog, name)
            records = getAll(catalog.PropertySetRecord, name);
        end
        
        function records = getAllVisibleInteractions(catalog)
            methodCalls = catalog.MethodCallRecord.findAll(@(record)ismember(record.Name, catalog.VisibleMethodNames));
            propertyAccesses = catalog.PropertyGetRecord.findAll(@(record)ismember(record.Name, catalog.VisiblePropertyNames));
            propertyModifications = catalog.PropertySetRecord.findAll(@(record)ismember(record.Name, catalog.VisiblePropertyNames));
            
            records = [methodCalls, propertyAccesses, propertyModifications];
            [~, idx] = sort([records.ID]);
            records = records(idx);
        end
    end
    
    methods (Access=private)
        function incrementInteractionCount(catalog)
            catalog.Count = catalog.Count + 1;
        end
    end
end

function entry = lookup(behavior, specification)
entry = specification.findFirst(@(other)behavior.describedBy(other));
end

function count = getCount(behavior, record)
count = numel(record.findAll(@(other)other.describedBy(behavior)));
end

function records = getAll(list, name)
records = list.findAll(@(record)record.Name == name);
end
