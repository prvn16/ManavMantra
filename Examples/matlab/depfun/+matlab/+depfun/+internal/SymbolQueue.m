classdef SymbolQueue < handle
% SymbolQueue A set that remembers the order in which elements were inserted.
% Elements are inserted at the back of a list and removed from the front.
% Clients may examine the first and last elements without removing them from
% the queue.

    properties(Access = protected)
        List
        LookupMap
    end
    properties(Dependent)
        NumEntries
    end
    methods
        function obj = SymbolQueue
            obj.List = {};
            obj.LookupMap = containers.Map('KeyType', 'char', ...
                                           'ValueType', 'logical');
        end

        function n = get.NumEntries(q)
            n = length(q.List);
        end
        
        function inQ = inQueue(q, target)
            inQ = isKey(q.LookupMap, target.WhichResult);
        end

        function enqueue(q, v)
        % enqueue Insert a element if it isn't already in the queue.
        % If the input is a cell array, insert each element separately.
            if isscalar(v) || (ischar(v) && numel(v) == length(v))
                if ~inQueue(q, v)
                    q.List{end+1} = v;
                    q.LookupMap(v.WhichResult) = true;
                end
            elseif iscell(v)
                for k=1:length(v)
                    if ~inQueue(q, v{k})
                        q.List{end+1} = v{k};
                        q.LookupMap(v{k}.WhichResult) = true;
                    end
                end
            end
        end
        
        function v = first(q)
        % first Return the first element without removing it.
            v = q.List{1};
        end
        
        function v = last(q)
        % last Return the last element without removing it.
            v = q.List{end};
        end
        
        function v = dequeue(q)
        % dequeue Remove the first element and return it.
            v = q.List{1};
            q.List(1) = [];
            remove(q.LookupMap, v.WhichResult);
        end
        
        function tf = isempty(q)
        % isempty Anybody waiting in line?
            tf = isempty(q.List);
        end
    end
            
end
