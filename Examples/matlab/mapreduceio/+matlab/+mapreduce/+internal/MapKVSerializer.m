classdef (Hidden) MapKVSerializer < matlab.mapreduce.internal.AbstractKVSerializer
%MAPKVSERIALIZER A serializer to flush mapper keys and values to disk.
%   MapKVSerializer Methods:
%   serialize - Serialize given key-value pairs to disk
%
%   See also datastore, mapreduce.

%   Copyright 2014 The MathWorks, Inc.

    properties (Access = private)
        % An internal serializer to flush mapper keys and values to disk.
        Serializer;
    end

    properties (Constant = true, Access = private)
        DEFAULT_FLUSH_LIMIT = 10 * 1024 * 1024; % 10 MB
        %DEFAULT_FLUSH_LIMIT = 0;
    end

    methods (Hidden = true)
        function mkvsr = MapKVSerializer(serializer)
            mkvsr.Serializer = serializer;
        end

        function tf = serialize(mkvsr, keys, values, bytesUsed, varargin)
        %serialize(kvsr, keys, values, varargin)
        %   Serialize given key-value pairs to disk appropriate for the
        %   keyvaluestore that owns this Serializer.

            tf = false;
            if bytesUsed > matlab.mapreduce.internal.MapKVSerializer.DEFAULT_FLUSH_LIMIT
                if nargin > 4
                    sizeToSerialize = varargin{1};
                    keys = keys(1:sizeToSerialize);
                    values = values(1:sizeToSerialize);
                end
                mkvsr.Serializer.addKeyValue(keys, values);
                tf = true;
            end
        end
    end
end % classdef end
