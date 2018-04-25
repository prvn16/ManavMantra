%GroupedBroadcast
% A broadcasted map from a set of keys to a set of values.
%
% This is used by splitapply when reduction within a group generates a
% single slice that through singleton expansion can be reused with the
% group.
%

% Copyright 2016-2017 The MathWorks, Inc.

classdef GroupedBroadcast < handle
    properties (SetAccess = immutable)
        % An array of slices that represent the keys.
        Keys
        
        % An array of slices that represent the values. Each value is
        % associated with one key.
        Values
    end
    
    methods
        % The main constructor.
        function obj = GroupedBroadcast(keys, values)
            assert(isnumeric(keys) && issorted(keys), ...
                'Assertion failed: GroupedBroadcast must be constructed with numeric keys.');
            assert(numel(keys) == numel(values), ...
                'Assertion failed: GroupedBroadcast must contain same number of keys and values.');
            obj.Keys = keys(:);
            obj.Values = values(:);
        end
    end
end
