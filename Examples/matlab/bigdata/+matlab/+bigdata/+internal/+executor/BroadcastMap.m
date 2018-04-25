%BroadcastMap
% Helper class that holds a map of ID to broadcast values.
%
% This supports setting either the entire broadcast value, or partitions of
% it. The broadcast value stored in this object is expected to be complete
% before it can be retrieved.
%

%   Copyright 2016 The MathWorks, Inc.

classdef (Sealed) BroadcastMap < handle
    
    properties (SetAccess = immutable)
        % The underlying containers.Map object.
        Map
    end
    
    methods
        % The main constructor.
        function obj = BroadcastMap()
            obj.Map = containers.Map('KeyType', 'char', 'ValueType', 'any');
        end
        
        % Check which of the given keys are a member of this object.
        function tfArray = ismember(obj, keys)
            map = obj.Map;
            existingKeys = map.keys;
            tfArray = ismember(keys, existingKeys);
        end
        
        % Set the entirety of the broadcast value.
        function set(obj, key, value)
            map = obj.Map;
            map(key) = {value}; %#ok<NASGU>
        end
        
        % Get the entirety of the broadcast value.
        function value = get(obj, key)
            map = obj.Map;
            entry = map(key);
            if iscell(entry)
                value = entry{1};
            else
                value = entry.values;
                value = vertcat(value{:});
                map(key) = {value}; %#ok<NASGU>
            end
        end
        
        % Set the specific partition indices of the given broadcast value.
        %
        % This will have no effect if the given broadcast value is already
        % complete.
        function setPartitions(obj, key, partitionIndices, values)
            map = obj.Map;
            innerMap = [];
            if isKey(map, key)
                innerMap = map(key);
                if iscell(innerMap)
                    innerMap = [];
                end
            end
            if isempty(innerMap)
                innerMap = containers.Map('KeyType', 'double', 'ValueType', 'any');
                map(key) = innerMap; %#ok<NASGU>
            end
            
            for ii = 1:numel(partitionIndices)
                innerMap(partitionIndices(ii)) = values{ii}; %#ok<AGROW>
            end
        end
        
        % Get the stored partitions for a given broadcast value.
        function [partitionIndices, values] = getPartitions(obj, key)
            map = obj.Map;
            entry = map(key);
            if iscell(entry)
                partitionIndices = 1;
                values = entry;
            else
                partitionIndices = entry.keys;
                partitionIndices = vertcat(partitionIndices{:});
                values = entry.values;
                values = values(:);
            end
        end
    end
end
