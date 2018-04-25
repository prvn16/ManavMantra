%MapReducerStackNode
% Helper class that represents a stack position in the list of soft
% references to MapReducers

%   Copyright 2014 The MathWorks, Inc.

classdef (Sealed, Hidden) MapReducerStackNode < handle & matlab.mapreduce.internal.SoftReferableMixin
    properties (SetAccess = private)
        Next; % The next node in this list.
        SoftRef; % A soft reference to the mapreducer corresponding to this node.
    end
    
    properties (Access = private)
        % A soft back reference to the previous node. This is a soft
        % reference because this avoids the cyclic references of a
        % doubly-linked list.
        SoftPrev;
    end
    
    methods
        % Insert this node after the given node in the list.
        function insertAfter(obj, node)
            validateattributes(node, {'matlab.mapreduce.internal.MapReducerStackNode'}, {'scalar'});
            obj.removeFromList();
            
            obj.Next = node.Next;
            if ~isempty(obj.Next)
                obj.Next.SoftPrev = obj.hGetSoftReference();
            end
            
            node.Next = obj;
            obj.SoftPrev = node.hGetSoftReference();
        end
        
        % Remove this node from the list of all MapReducer stack nodes.
        function removeFromList(obj)
            next = obj.Next;
            softPrev = obj.SoftPrev;
            prev = [];
            if ~isempty(softPrev)
                prev = get(softPrev);
            end
            
            obj.Next = [];
            obj.SoftPrev = [];
            if ~isempty(next)
                next.SoftPrev = softPrev;
            end
            if ~isempty(prev)
                prev.Next = next;
            end            
        end
        
        function delete(obj)
            removeFromList(obj);
        end
    end
    
    methods (Hidden, Static)
        % Build a node that does not correspond to any MapReducer.
        % This should only be used by MapReducerManager.
        function obj = hBuildEmptyNode()
            import matlab.mapreduce.internal.MapReducerStackNode;
            obj = MapReducerStackNode();
        end
        
        % Build a node that contains a soft reference to the given MapReducer.
        % This should only be used by MapReducer.
        function obj = hBuildNode(mapReducer)
            import matlab.mapreduce.internal.MapReducerStackNode;
            validateattributes(mapReducer, {'matlab.mapreduce.MapReducer'}, {'scalar'});
            obj = MapReducerStackNode(mapReducer);
        end
    end
    
    methods (Access = private)
        % Private constructor for the hidden build methods.
        function obj = MapReducerStackNode(mapReducer)
            if nargin >= 1
                obj.SoftRef = mapReducer.hGetSoftReference();
                obj.SoftRef.addlistener('ReferenceInvalidated', @obj.pHandleInvalidatedReference);
            end
        end
        
        % Callback function that is triggered when the MapReducer
        % corresponding to this node is deleted.
        function pHandleInvalidatedReference(obj, ~, ~)
            removeFromList(obj);
        end
    end
end
