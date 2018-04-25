%KeyValueStoreWriter
% Helper class that encapsulates writing to a matlab.mapreduce.internal.KeyValueStore.
%

%   Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) KeyValueStoreWriter < matlab.bigdata.internal.io.Writer
    properties (SetAccess = immutable)
        % The underlying KeyValueStore implementation.
        SqliteStore;
        
        % The default key should none be provided to the add method.
        DefaultKey;
    end
    
    properties (SetAccess = private)
        % Flag describing whether this instance has already committed results to disk.
        Committed = false;
    end
    
    properties (Constant)
        % Commit comment for use with KeyValueStore.
        CommitComment = 'Commit by KeyValueStoreWriter';
        
        % The name to use for the table in the KeyValueStore.
        TableName = 'Store';
    end
    
    methods
        % Construct a writer that will write data to a KeyValueStore.
        function obj = KeyValueStoreWriter(targetFile, defaultKey)
            import matlab.bigdata.internal.serial.KeyValueStoreWriter;
            
            obj.SqliteStore = matlab.mapreduce.internal.KeyValueStore(targetFile, 'createIfNecessary', 'doNotDelete');
            obj.DefaultKey = defaultKey;
            
            obj.SqliteStore.beginTransaction(KeyValueStoreWriter.CommitComment);
            if ~obj.SqliteStore.storeExists(KeyValueStoreWriter.TableName)
                obj.SqliteStore.createStore(KeyValueStoreWriter.TableName);
                obj.SqliteStore.createStoreKeyIndex(KeyValueStoreWriter.TableName);
                obj.SqliteStore.setStoreKeyType(0);
            end
            obj.SqliteStore.selectStoreToWrite(KeyValueStoreWriter.TableName);
        end
        
        % Throw away all non-committed output so that failed or cancelled
        % tasks do not insert any data into the output.
        function delete(obj)
            import matlab.bigdata.internal.serial.KeyValueStoreWriter;
            if ~obj.Committed
                obj.SqliteStore.rollbackTransaction(KeyValueStoreWriter.CommitComment);
            end
        end
    end
    
    % Overrides of matlab.bigdata.internal.io.Writer methods.
    methods
        % Add a collection of<key, value> pairs to the intermediate storage.
        function add(obj, keys, values)
            assert (~obj.Committed, ...
                'Assertion failed: Attempted to write to a KeyValueStore that is already committed.');
            if isempty(values)
                return;
            elseif isempty(keys)
                keys = obj.DefaultKey;
            end
            
            if isscalar(keys)
                values = {values};
            else
                assert(numel(keys) == size(values, 1), ...
                    'Assertion failed: Number of keys does not match number of values.');
                keys = keys(:);
                values = num2cell(values, 2:ndims(values));
            end
            obj.SqliteStore.addKeyValue(keys, values);
        end
        
        % Commit all output to the intermediate storage.
        function commit(obj)
            import matlab.bigdata.internal.serial.KeyValueStoreWriter;
            assert (~obj.Committed, ...
                'Assertion failed: Attempted to commit to a KeyValueStore that is already committed.');
            obj.SqliteStore.commitTransaction(KeyValueStoreWriter.CommitComment);
            obj.Committed = true;
        end
    end
end
