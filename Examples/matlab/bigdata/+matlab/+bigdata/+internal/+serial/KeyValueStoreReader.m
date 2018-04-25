%KeyValueStoreReader
% Helper class that encapsulates reading from a matlab.mapreduce.internal.KeyValueStore.
%

%   Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed, Hidden) KeyValueStoreReader < matlab.bigdata.internal.io.Reader
    properties (SetAccess = immutable)
        % The underlying KeyValueStore implementation.
        KeyValueStore;
        
        % The collection of keys that correspond to the data to be read.
        SelectedKeys;
    end
    
    properties (SetAccess = private)
        % A flag that describes whether there is any further data to be
        % read.
        HasData = false;
    end
    
    methods
        % Construct a reader that will read data from a KeyValueStore.
        function obj = KeyValueStoreReader(storeFile, selectedKeys)
            import matlab.bigdata.internal.serial.KeyValueStoreWriter;
            
            if nargin < 2
                selectedKeys = [];
            end
            
            obj.KeyValueStore = matlab.mapreduce.internal.KeyValueStore(storeFile, 'createIfNecessary', 'doNotDelete');
            obj.SelectedKeys = selectedKeys;
            
            if ~obj.KeyValueStore.storeExists(KeyValueStoreWriter.TableName)
                return;
            end
            obj.KeyValueStore.selectStoreToRead(KeyValueStoreWriter.TableName);
            
            obj.findNextKey();
        end
    end
    
    % Overrides of matlab.bigdata.internal.io.Reader methods.
    methods
        % Query whether any more data exists.
        function out = hasdata(obj)
            out = obj.HasData;
        end
        
        % Read the next chunk of data.
        function data = read(obj)
            assert (obj.HasData, ...
                'Assertion failed: Attempted to read from a KeyValueStoreReader with no data.');
            data = obj.KeyValueStore.getNextValue();
            
            obj.HasData = obj.KeyValueStore.hasNextValue();
            if ~obj.HasData
                obj.findNextKey()
            end
        end
    end
    
    methods (Access = private)
        % Search through the store for any keys that matches selected keys.
        function findNextKey(obj)
            assert (~obj.HasData, ...
                'Assertion failed: Attempted to move to next key before all data has been read from the current key.');
            while obj.KeyValueStore.hasNextKey()
                currentKey = obj.KeyValueStore.getNextKey();
                if (isempty(obj.SelectedKeys) || any(currentKey == obj.SelectedKeys)) ...
                        && obj.KeyValueStore.hasNextValue()
                    obj.HasData = true;
                    return;
                end
            end
        end
    end
end
