classdef (Hidden) TextKeyValueProcessor < matlab.mapreduce.internal.KeyValueProcessor
%
%   See also datastore, mapreduce.

%   Copyright 2014 The MathWorks, Inc.
    properties (Hidden, Access = public)
    %ValueType - The type of the Value the TextKeyValueProcessor holds on
    %to check if all the values are of same type.
        ValueType;
    end

    properties (Constant, Access = private)
        VALUES_STR_FOR_ERRORID = 'Values';
    end

    methods (Access = protected)
        function checkHomogeneousValue(kvp, values)
            %CHECKHOMOGENEOUSVALUE(kvp, values)
            % Check if all the values added so far are of the same data type
            if iscell(values)
                sampleValue = values{1};
            else
                sampleValue = values(1);
            end
            if isempty(kvp.ValueType)
                setStoreValueType(kvp, sampleValue);
                return;
            end
            vType = class(sampleValue);
            if ~(strcmp(kvp.ValueType, vType))
                error(message('MATLAB:mapreduceio:textkeyvalueprocessor:nonHomogeneousValues', kvp.ValueType, vType));
            end
        end
        
        function setStoreValueType(kvp, sampleValue)
            %setStoreValueType(kvp, sampleValue)
            % Set the ValueType property to the sampleValue's data type.
            kvp.ValueType = class(sampleValue);
        end

        function values = processMultiValues(kvp, values)
            % Process values: values follow the same rules as keys
            values = processMultiNumericScalarsOrStrings(kvp, values, ...
                matlab.mapreduce.internal.TextKeyValueProcessor.VALUES_STR_FOR_ERRORID);
        end

    end

    methods (Access = public, Hidden = true)

        function value = processSingleValue(kvp, value)
            %processSingleValue
            % Check if values are either a string or a numeric scalar.
            % A single value cannot be a cell or a numeric vector.
            import matlab.mapreduce.internal.TextKeyValueProcessor;
            import matlab.mapreduce.internal.isNonSingle;
            if isNonSingle(value, TextKeyValueProcessor.VALUES_STR_FOR_ERRORID)
                error(message('MATLAB:mapreduceio:textkeyvalueprocessor:nonSingleValue'));
            end
            if ischar(value)
                value = {value};
            end
            checkHomogeneousValue(kvp, value);
        end

        function [keys, values, empty] = processMultiKeysValues(kvp, keys, values)
            [keys, values, empty] = processMultiKeysValues@matlab.mapreduce.internal.KeyValueProcessor(kvp, keys, values);
            if empty
                return;
            end
            % Check for homogeneity
            checkHomogeneousValue(kvp, values);
        end
    end % methods end

end % classdef end