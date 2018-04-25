classdef InspectorUndoService < internal.matlab.datatoolsservices.UndoService
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Extends the UndoService to provide an Inspector-specific version
    % of the service.
    
    % Copyright 2017 The MathWorks, Inc.

    methods
        % Creates a new InspectorUndoQueue for use by the service
        function q = createNewUndoQueue(~)
            q = internal.matlab.inspector.InspectorUndoQueue;
        end
    end
    
    methods(Static)
        % Returns an instance of the InspectorUndoService
        function obj = getInstance()
            mlock; % Keep persistent variables until MATLAB exits
            persistent undoServiceInstance;
            if isempty(undoServiceInstance) || ~isvalid(undoServiceInstance)
                % Create a new UndoService
                undoServiceInstance = internal.matlab.inspector.InspectorUndoService;
            end
            
            obj = undoServiceInstance;
        end
    end
end
