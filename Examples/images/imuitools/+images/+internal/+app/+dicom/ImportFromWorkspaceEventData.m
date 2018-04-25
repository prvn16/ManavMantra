classdef (ConstructOnLoad) ImportFromWorkspaceEventData < event.EventData
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties
        Collection
    end
    
    methods
        function data = ImportFromWorkspaceEventData(collection_)
            data.Collection = collection_;
        end
    end
end