classdef (Hidden) KeyValueVector < handle
%KEYVALUEVECTOR Maintains vectorized keys and values in-memory.
%   KeyValueVector Methods:
%   append - Append keys and values to an internal vector.
%
%   See also datastore, mapreduce.

%   Copyright 2014-2016 The MathWorks, Inc.

    properties (Access = public, Hidden = true)
        KeyVector;
        ValueVector;
        CurrentCapacity;
        BytesUsed;
        SizeBuffered;
        IsKeyCell;
        IsValueCell;
    end

    properties (Constant, Access=private)
        DEFAULT_INITIAL_CAPACITY = 1000;
    end

    methods (Access = private)
        function ensureCapacity(kvv, sizeToEnsure, keys, values)
            if sizeToEnsure <= kvv.CurrentCapacity
                return;
            end
            if kvv.CurrentCapacity == 0
                import matlab.mapreduce.internal.KeyValueVector;
                kvv.CurrentCapacity = KeyValueVector.DEFAULT_INITIAL_CAPACITY;
            end
            amortizedCapIncrease = kvv.CurrentCapacity;
            if sizeToEnsure > 2 * amortizedCapIncrease
                amortizedCapIncrease = sizeToEnsure * 2 - amortizedCapIncrease;
            end
            increaseCapacity(kvv, amortizedCapIncrease, keys, values);
        end

        function increaseCapacity(kvv, capacityIncrease, keys, values)
            incCell = cell(capacityIncrease, 1);
            if isempty(kvv.IsKeyCell)
                isKeyValueCells(kvv, keys, values);
            end
            if kvv.IsKeyCell
                kvv.KeyVector = [kvv.KeyVector; incCell];
            else
                incZeros = zeros(capacityIncrease, 1, 'like', keys);
                kvv.KeyVector = [kvv.KeyVector; incZeros];
            end
            if kvv.IsValueCell
                kvv.ValueVector = [kvv.ValueVector; incCell];
            else
                incZeros = zeros(capacityIncrease, 1, 'like', values);
                kvv.ValueVector = [kvv.ValueVector; incZeros];
            end
            kvv.CurrentCapacity = kvv.CurrentCapacity + capacityIncrease;
        end

        function isKeyValueCells(kvv, keys, values)
            kvv.IsKeyCell = false;
            kvv.IsValueCell = false;
            if iscell(keys)
                kvv.IsKeyCell = true;
            end
            if iscell(values)
                kvv.IsValueCell = true;
            end
        end
    end

    methods (Access = public, Hidden = true)
        function kvv = KeyValueVector()
            initialize(kvv);
        end

        function initialize(kvv)
            import matlab.mapreduce.internal.KeyValueVector;
            kvv.CurrentCapacity = 0;
            kvv.BytesUsed = 0;
            kvv.SizeBuffered = 0;
        end
        
        function append(kvv, keys, values)
            % append(kvv, keys, values) - An implementation to append keys and
            % values provided to an internal vector that will be spilled over to
            % disk using serialize() method in a KVSerializer. This method adds
            % the byte size of the keys and values to the property BytesUsed,
            % which indicates the bytes used by the internal vector holding all
            % the keys and values.
            if matlab.mapreduce.internal.anyHandleValue(values)
                kvv.BytesUsed = inf;
            else
                w = whos('keys', 'values');
                kvv.BytesUsed = kvv.BytesUsed + sum([w.bytes]);
            end
            nk = numel(keys);
            endIdx = kvv.SizeBuffered + nk;
            ensureCapacity(kvv, endIdx, keys, values);
            kvv.KeyVector(kvv.SizeBuffered+1:endIdx) = keys;
            kvv.ValueVector(kvv.SizeBuffered+1:endIdx) = values;
            kvv.SizeBuffered = kvv.SizeBuffered + nk;
        end
    end
end % classdef end
