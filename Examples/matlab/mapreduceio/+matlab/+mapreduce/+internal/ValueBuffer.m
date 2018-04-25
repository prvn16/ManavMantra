classdef (Hidden) ValueBuffer < handle
%VALUEBUFFER Maintains vectorized values in-memory.
%   ValueBuffer Methods:
%   append - Append values to an internal buffer.
%
%   See also datastore, mapreduce, tall.

%   Copyright 2016 The MathWorks, Inc.

    properties (Access = public, Hidden = true)
        % Buffer that holds the values
        Buffer;
        % The capacity of the Buffer at particular state
        CurrentCapacity;
        % Bytes used by the Buffer so far.
        BytesUsed;
        % Number of values buffered so far.
        SizeBuffered;
        % Boolean on whether the value is a cell or not.
        IsValueCell;
    end

    properties (Constant, Access=private)
        DEFAULT_INITIAL_CAPACITY = 1000;
    end

    methods (Access = private)
        function ensureCapacity(vv, sizeToEnsure, values)
            %ensureCapacity - Ensures capacity of the internal buffer
            %   Check if the capacity of the internal buffer is good enough
            %   to add the given values. If not an amortized capacity value
            %   is added to the buffer.
            if sizeToEnsure <= vv.CurrentCapacity
                return;
            end
            if vv.CurrentCapacity == 0
                import matlab.mapreduce.internal.ValueBuffer;
                vv.CurrentCapacity = ValueBuffer.DEFAULT_INITIAL_CAPACITY;
            end
            amortizedCapIncrease = vv.CurrentCapacity;
            if sizeToEnsure > 2 * amortizedCapIncrease
                amortizedCapIncrease = sizeToEnsure * 2 - amortizedCapIncrease;
            end
            increaseCapacity(vv, amortizedCapIncrease, values);
        end

        function increaseCapacity(vv, capacityIncrease, values)
            %increaseCapacity - Increase capacity of the internal buffer
            %   If the buffer is cell, increase the cell array capacity
            %   otherwise increase the capacity using zeros.
            incCell = cell(capacityIncrease, 1);

            if isempty(vv.IsValueCell)
                isValueACell(vv, values);
            end

            if vv.IsValueCell
                vv.Buffer = [vv.Buffer; incCell];
            else
                incZeros = zeros(capacityIncrease, 1, 'like', values);
                vv.Buffer = [vv.Buffer; incZeros];
            end
            vv.CurrentCapacity = vv.CurrentCapacity + capacityIncrease;
        end

        function isValueACell(vv, values)
            %isValueACell - Check if the values is a cell
            %   Check if values is cell and cache the buffer objects property
            %   IsValueCell.
            vv.IsValueCell = false;
            if iscell(values)
                vv.IsValueCell = true;
            end
        end
    end

    methods (Access = public, Hidden = true)
        function vv = ValueBuffer()
            %Constructor for ValueBuffer
            %   Initialize the buffer values.
            initialize(vv);
        end

        function initialize(vv)
            %Initialize buffer values in ValueBuffer
            vv.CurrentCapacity = 0;
            vv.BytesUsed = 0;
            vv.SizeBuffered = 0;
            vv.Buffer = [];
            vv.IsValueCell = [];
        end

        function append(vv, values)
            % append(vv, values) - An implementation to append values provided
            % to an internal vector that will be spilled over to
            % disk using serialize() method in a Serializer. This method adds
            % the byte size of the values to the property BytesUsed,
            % which indicates the bytes used by the internal vector holding all
            % the keys and values.
            if matlab.mapreduce.internal.anyHandleValue(values)
                vv.BytesUsed = inf;
            else
                w = whos('values');
                vv.BytesUsed = vv.BytesUsed + sum([w.bytes]);
            end
            nk = numel(values);
            endIdx = vv.SizeBuffered + nk;
            ensureCapacity(vv, endIdx, values);
            vv.Buffer(vv.SizeBuffered+1:endIdx) = values;
            vv.SizeBuffered = vv.SizeBuffered + nk;
        end
    end
end % classdef end
