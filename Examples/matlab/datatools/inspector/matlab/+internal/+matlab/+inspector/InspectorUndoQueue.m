classdef InspectorUndoQueue < internal.matlab.datatoolsservices.UndoQueue
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % UndoQueue for use by the Property Inspector.
    
    % Copyright 2017 The MathWorks, Inc.

    methods(Access = public)
        % Creates an InspectorUndoQueue instance
        function this = InspectorUndoQueue()
            this@internal.matlab.datatoolsservices.UndoQueue(...
                internal.matlab.inspector.InspectorUndoableCommand.empty());
        end
    end
end
