classdef KeyValueStore < matlab.mapreduce.internal.AbstractKeyValueStore...
                         & matlab.mixin.CustomDisplay
%KEYVALUESTORE Store key-value pairs for use with mapreduce.
%   KeyValueStore objects are used within MAPREDUCE
%
%      OUTDS = MAPREDUCE(INDS,MAPFUN,REDUCEFUN,...)
% 
%   where MAPFUN and REDUCEFUN are functions:
% 
%      MAPFUN(data,info,KVstore)
%      REDUCEFUN(key,valsIter,KVstore)
% 
%   Within MAPFUN or REDUCEFUN, add one or more key-value pairs
%   to the KeyValueStore KVstore using
% 
%      ADD(KVstore,key,val)
%      ADDMULTI(KVstore,{key1; key2; ...},{val1; val2; ...})
%  
%   All keys added must obey the following rules:
%       1. Keys can be numeric scalars or strings.
%       2. All keys added by the map function must have the same class.
%       3. All keys added by the reduce function must have the same class,
%          but may differ from the class of the keys added by the map
%          function.
%
%   KeyValueStore Methods:
%     add      - Adds a single key-value pair to the KeyValueStore.
%     addmulti - Adds multiple key-value pairs to the KeyValueStore. 
% 
%   Example:
%        add(kvs,'sumAndLength',[1524234, 20000])
%        addmulti(kvs,{'sum';'length'},{1524234; 20000})
% 
%   See also mapreduce.

%   Copyright 2014 The MathWorks, Inc.
    properties (Access = private)
        KVVector;
        KVSerializer;
        KVProcessor;
    end
    % Caching for custom display
    properties (Access = private)
        Cache3Keys;
        Cache3Values;
    end
    
    properties (Constant, Access = private)
        AHREF_CUSTOM_DISPLAY_ADD_LINK = '<a href="matlab: help(''matlab.mapreduce.KeyValueStore\add'')">add</a>';
        AHREF_CUSTOM_DISPLAY_ADDMULTI_LINK = '<a href="matlab: help(''matlab.mapreduce.KeyValueStore\addmulti'')">addmulti</a>';
        MSG_CTLG_PREFIX = 'MATLAB:mapreduceio:keyvaluestore:';
    end

    methods (Access = private)
        function appendAndSerialize(kvs, keys, values)
            append(kvs.KVVector, keys, values);
            updateCache(kvs, keys, values);
            if serialize(kvs.KVSerializer, kvs.KVVector.KeyVector, ...
                    kvs.KVVector.ValueVector, kvs.KVVector.BytesUsed, ...
                    kvs.KVVector.SizeBuffered)
                kvs.KVVector.initialize();
            end
        end

        function updateCache(kvs, keys, values)
            stidx = trail3idx(keys);
            kvs.Cache3Keys = [kvs.Cache3Keys; keys(stidx:end)];
            kvs.Cache3Values = [kvs.Cache3Values; values(stidx:end)];
            stidx = trail3idx(kvs.Cache3Keys);
            kvs.Cache3Keys = kvs.Cache3Keys(stidx:end);
            kvs.Cache3Values = kvs.Cache3Values(stidx:end);
        end
    end

    methods (Hidden, Access = public)
        function clearCache(kvs)
            kvs.Cache3Keys = [];
            kvs.Cache3Values = [];
        end

        function flush(kvs)
            if numel(kvs.KVVector.KeyVector) > 0
                serialize(kvs.KVSerializer, kvs.KVVector.KeyVector,...
                         kvs.KVVector.ValueVector, inf, kvs.KVVector.SizeBuffered);
            end
        end
    end
    methods (Access = protected)
        function header = getHeader(kvs)
            import matlab.mapreduce.KeyValueStore;

            className = matlab.mixin.CustomDisplay.getClassNameForHeader(kvs);
            containingKeysStr = 'noKVPairs';
            keyType = '';
            % Find if type of keys added are numeric scalars or strings.
            % kvTypeStr is the message catalog string used to get localized
            % messages for KeyValueStore display.
            kvTypeStr = 'scalarOrStringKeys';
            if ~isempty(kvs.KVProcessor.KeyType)
                keyType = kvs.KVProcessor.KeyType;
                if ~strcmp(keyType, 'char')
                    containingKeysStr = 'containingNumericKeys';
                    kvTypeStr = 'scalarKeys';
                else
                    containingKeysStr = 'containingStringKeys';
                    kvTypeStr = 'stringKeys';
                end
            end

            headerStr = getString(message([KeyValueStore.MSG_CTLG_PREFIX, containingKeysStr], className));

            % Find if type of values added are numeric scalars or strings.
            % Only when OutputType = 'tabulartext', values can be numeric or strings
            % All other cases, values can be any type.
            if isa(kvs.KVProcessor, 'matlab.mapreduce.internal.TextKeyValueProcessor')
                kvTypeStr = catValueTypeStr(kvs, kvTypeStr, keyType);
            else
                kvTypeStr = [kvTypeStr, 'AnyValues'];
            end

            bodyStr = getString(getBodyMsg(kvs, kvTypeStr));
            header = sprintf('%s\n\n%s\n', headerStr, bodyStr);
        end

        function kvTypeStr = catValueTypeStr(kvs, kvTypeStr, keyType)
            if isempty(kvs.KVProcessor.ValueType)
                kvTypeStr = [kvTypeStr, 'ScalarOrStringValues'];
                return;
            end

            switch kvs.KVProcessor.ValueType
                case 'char'
                    kvTypeStr = [kvTypeStr, 'StringValues'];
                case keyType
                    kvTypeStr = 'sameScalarKeysAndValues';
                otherwise
                    kvTypeStr = [kvTypeStr, 'ScalarValues'];
            end
        end

        function msg = getBodyMsg(kvs, kvTypeStr)
            import matlab.mapreduce.KeyValueStore;
            switch kvTypeStr
                case 'scalarKeysScalarValues'
                    msg = message([KeyValueStore.MSG_CTLG_PREFIX, kvTypeStr],...
                        kvs.KVProcessor.KeyType, kvs.KVProcessor.ValueType);
                case {'scalarKeysAnyValues', 'scalarKeysScalarOrStringValues', 'scalarKeysStringValues'}
                    msg = message([KeyValueStore.MSG_CTLG_PREFIX, kvTypeStr], kvs.KVProcessor.KeyType);
                case {'stringKeysScalarValues', 'scalarOrStringKeysScalarValues', 'sameScalarKeysAndValues'}
                    msg = message([KeyValueStore.MSG_CTLG_PREFIX, kvTypeStr], kvs.KVProcessor.ValueType);
                otherwise
                    msg = message([KeyValueStore.MSG_CTLG_PREFIX, kvTypeStr]);
            end
        end

        function footer = getFooter(~)
            import matlab.mapreduce.KeyValueStore;
            addStr = 'add';
            addMultiStr = 'addmulti';
            if feature('hotlinks')
                addStr = KeyValueStore.AHREF_CUSTOM_DISPLAY_ADD_LINK;
                addMultiStr = KeyValueStore.AHREF_CUSTOM_DISPLAY_ADDMULTI_LINK;
            end
            useMethodStr = getString(message(...
                [KeyValueStore.MSG_CTLG_PREFIX, 'useMethodsCustomDisp'], ...
                addStr, ...
                addMultiStr));
            footer = sprintf('%s\n', useMethodStr);
        end

        function displayScalarObject(kvs) %#ok<DISPLAY>
            disp(getHeader(kvs));
            if ~isempty(kvs.Cache3Keys)
                import matlab.mapreduce.KeyValueStore;
                t = table;
                t.Key = kvs.Cache3Keys;
                t.Value = kvs.Cache3Values;
                numkv = numel(kvs.Cache3Keys);
                lastKVPairsStr = getString(message(...
                    [KeyValueStore.MSG_CTLG_PREFIX, 'lastKVPairs'], numel(kvs.Cache3Keys)));
                if numkv == 1
                    lastKVPairsStr = getString(message([KeyValueStore.MSG_CTLG_PREFIX, 'lastOneKVPair']));
                end
                disp(lastKVPairsStr);
                disp(' ');
                disp(t);
            end
            disp(getFooter(kvs));
        end
    end

    methods (Access = public)
        function kvs = KeyValueStore(kvsr, kvp, kvv)
            kvs.KVSerializer = kvsr;
            kvs.KVProcessor = kvp;
            kvs.KVVector = kvv;
        end
        
        function addmulti(kvs, keys, values)
            %ADDMULTI Add multiple key-value pairs to a KeyValueStore.
            % ADDMULTI(KVS,KEYS,VALUES) adds multiple key-value pairs to KVS.
            % KEYS can be a numeric array or a cell array containing numeric
            % or strings keys.
            % VALUES must be a cell array, but the elements of the cell array
            % can be of any class.
            %
            % Example:
            %   addmulti(kvs,[1 2 3],{[1 2; 3 4]; [5 6; 7 8]; [9 10; 11 12]})
            %   addmulti(kvs,{'sum'; 'length'},{1524234; 20000})
            %
            % See also matlab.mapreduce.KeyValueStore, add, mapreduce.            
            try
                [keys, values, empty] = processMultiKeysValues(kvs.KVProcessor, keys, values);
                if empty
                     % If keys and values added are empty, KeyValueStore
                     % need not add them, but ignore; only in addmulti.
                    return;
                end
                appendAndSerialize(kvs, keys, values);
            catch e
                throwAsCaller(e);
            end
        end

        function add(kvs, key, value)
            %ADD Add a key-value pair to a KeyValueStore.
            % ADD(KVS,KEY,VALUE) adds a key-value pair to KVS.
            % KEY can be a numeric scalar or a string.
            % VALUE can be of any class including a cell array.
            %
            % Example:
            %   add(kvs,12,34)
            %   add(kvs,'key1',100)
            %   add(kvs,'sumAndLength',[1524234, 20000])
            %   add(kvs,'A',{ones(4),pi})
            %
            % See also matlab.mapreduce.KeyValueStore, addmulti, mapreduce.
            try
                key = processSingleKey(kvs.KVProcessor, key);
                value = processSingleValue(kvs.KVProcessor, value);
                appendAndSerialize(kvs, key, value);
            catch e
                throwAsCaller(e);
            end
        end

    end
end % classdef end
function idx = trail3idx(input)
numelem = numel(input);
idx = 1;
if numelem > 3
    idx = numelem - 2;
end
end
