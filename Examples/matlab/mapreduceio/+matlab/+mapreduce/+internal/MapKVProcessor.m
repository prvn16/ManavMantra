classdef (Hidden) MapKVProcessor < matlab.mapreduce.internal.KeyValueProcessor 
%MAPKVPROCESSOR Check rules to add keys and values, reshaping if needed.
%   MapKVProcessor Properties:
%   KeyType - The type of the key this KeyValueProcessor represents.
%   Store - An internal store that sets its KeyType with a sample key.
%
%   MapKVProcessor Methods:
%   setStoreKeyType - Set KeyType property to the sample key's data type.
%   process - Check if key-value pairs follow the rules to the add method.
%
%   See also datastore, mapreduce.

%   Copyright 2014 The MathWorks, Inc.

    properties (Access = private)
        % An internal store that sets its KeyType with a sample key.
        Store;
    end

    methods (Access = public, Hidden)
        function mkvp = MapKVProcessor(store)
            mkvp.Store = store;
        end
        function setStoreKeyType(kvp, sampleKey)
            kvp.KeyType = class(sampleKey);
            kvp.Store.setStoreKeyType(sampleKey);
        end
    end

end % classdef end
