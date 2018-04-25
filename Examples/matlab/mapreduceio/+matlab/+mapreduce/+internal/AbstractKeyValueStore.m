classdef (Hidden) AbstractKeyValueStore < handle
%ABSTRACTKEYVALUESTORE An interface to add keys and values.
%   This baseclass is an inteface to add keys and values to a KeyValueStore
%   in a mapper or a reducer.
%
%   See also mapreduce, matlab.mapreduce.MapKeyValueStore.

%   Copyright 2014 The MathWorks, Inc.

    methods (Access = public, Abstract)
        %add   Adds the provided single key-value pair to the KeyValueStore.
        %   Check if key and value obey the rules to the add method.
        %   Use process() method of KeyValueProcessor to check and process
        %   the keys and values to get the appropriate shape for keys and
        %   values.
        add(kvs, key, value);
        %addmulti Adds the provided mutliple key-value pairs to the KeyValueStore.
        %   Check if keys and values obey the rules to the addmulti method.
        %   Use process() method of KeyValueProcessor to check and process
        %   the keys and values to get the appropriate shape for keys and
        %   values.
        addmulti(kvds, keys, values);
    end

end % classdef end
