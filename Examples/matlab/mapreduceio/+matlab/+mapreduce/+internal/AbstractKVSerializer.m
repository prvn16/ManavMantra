classdef (Hidden) AbstractKVSerializer < handle
%ABSTRACTKVSERIALIZER A serializer to write keys and values to disk.
%
%   See also mapreduce, matlab.mapreduce.MapKeyValueStore.

%   Copyright 2014 The MathWorks, Inc.

    methods (Abstract)
        %serialize(kvsr, keys, values, varargin)
        %   Serialize given key-value pairs to disk appropriate for the
        %   keyvaluestore that owns this Serializer.
        %   Return logical true if serialized else return logical false.
        tf = serialize(kvsr, keys, values, varargin);
    end
end % classdef end
