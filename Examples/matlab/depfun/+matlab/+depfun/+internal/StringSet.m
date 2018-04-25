classdef StringSet < handle
% STRINGSET A set of strings. Uses containers.Map for fast insert and lookup.
% Not an error to add identical elements multiple times or to delete elements
% that don't exist.

    properties(Access=protected)
        data
    end
    
    properties(Dependent)
        Size
    end

    methods (Access=private)
        
        function insert(obj, str)
        % INSERT Insert a single string into the set.
            if ~isKey(obj.data, str)
                obj.data(str) = true;
            end
        end

        function withdraw(obj, str)
        % WITHDRAW Remove a single string from the set. Do nothing (no
        % error) if the string is not a member of the set.
            if isKey(obj.data, str)
                remove(obj.data, str);
            end
        end

    end
    
    methods

        function obj = StringSet(varargin)

            % Add input strings, if any, to the set.
            if nargin > 0
                obj.data = containers.Map(varargin, true(size(varargin)));
            else
                obj.data = containers.Map;
            end
        end

        function s = members(obj)
            s = keys(obj.data);
        end

        function add(obj, varargin)
        % ADD Add a single string, or a cell array of strings, to the set.
            for k=1:numel(varargin)
                insert(obj, varargin{k});
            end
        end

        function remove(obj, varargin)
        % REMOVE Remove a single string or a cell array of strings,
        % from the set.
            for k=1:numel(varargin)
                withdraw(obj, varargin{k});
            end
        end

        function tf = ismember(obj, varargin)
        % ISMEMBER Determine if one or more strings are in the set.
        % tf(k) is true if str{k} is in the set. str may be a single string
        % or a cell array of strings.
            tf = isKey(obj.data, varargin);
        end

        function n = get.Size(obj)
        % SIZE Return the number of strings in the set. 
        % A synthetic property.
            n = length(obj.data);
        end
        
    end
end
