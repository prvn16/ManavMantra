classdef UndoService < handle
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % UndoService for use by Data Tools components.  Contains a map
    % which stores a UndoQueues based on a unique identifier.
    
    % Copyright 2017 The MathWorks, Inc.

    properties(Access = protected)
        % Map containing the UndoQueues
        UndoQueueMap;
    end
    
    methods(Access = protected)
        % Create a new UndoService instance
        function this = UndoService()
            this.UndoQueueMap = containers.Map;
        end
    end
    
    methods
        % Get the Undo queue associated with the unique key.  A new
        % undo queue will be created if one doesn't exist for this key
        % yet.
        %
        % key - the unique key to get the Undo queue for
        % Returns the UndoQueue object for this key
        function queue = getUndoQueue(this, key)
            if this.UndoQueueMap.isKey(key)
                % Return the UndoQueue for the associated key
                queue = this.UndoQueueMap(key);
            else
                % Create a new UndoQueue and add it to the map
                queue = this.createNewUndoQueue();
                this.UndoQueueMap(char(string(key))) = queue;
            end
        end
        
        % Clear all contents from the UndoQueue Map
        function clearAll(this)
            this.UndoQueueMap.remove(keys(this.UndoQueueMap));
        end
    end
    
    methods(Abstract)
        % Called to create a new undo queue when needed
        createNewUndoQueue(this);
    end
end
