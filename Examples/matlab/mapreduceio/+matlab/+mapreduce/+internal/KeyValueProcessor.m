classdef (Hidden) KeyValueProcessor < handle
%KEYVALUEPROCESSOR Check rules to add keys and values, reshaping if needed.
%   KeyValueProcessor Properties:
%   KeyType - The type of the key this KeyValueProcessor represents.
%
%   KeyValueProcessor Methods:
%   checkHomogeneous - Check all keys added so far are of same data type.
%   checkSingleKey - Check if key is a char row vector or a scalar numeric.
%   setStoreKeyType - Set KeyType to the sample key's data type.
%   processMultiKeysValues - Check if key-value pairs follow the rules to the addmulti() method.
%
%   See also datastore, mapreduce.

%   Copyright 2014-2016 The MathWorks, Inc.

    properties (Access = public, Hidden)
    %KeyType - The type of the key the KeyValueProcessor owned by this
    %KeyValueStore represents. 
        KeyType;        
    end

    properties (Constant, Access = private)
        KEYS_STR_FOR_ERRORID = 'Keys';
    end

    methods (Access = protected)
        function checkHomogeneousKey(kvp, keys)
            %checkHomogeneousKey(kvp, keys)
            % Check if all the keys added so far are of the same data type
            if iscell(keys)
                sampleKey = keys{1};
            else
                sampleKey = keys(1);
            end
            if isempty(kvp.KeyType)
                setStoreKeyType(kvp, sampleKey);
                return;
            end
            kc = class(sampleKey);
            if ~(strcmp(kvp.KeyType, kc))
                error(message('MATLAB:mapreduceio:keyvalueprocessor:nonHomogeneousKey', kvp.KeyType, kc));
            end
        end

        function keys = processMultiKeys(kvp, keys)
            keys = processMultiNumericScalarsOrStrings(kvp, keys, ...
                matlab.mapreduce.internal.KeyValueProcessor.KEYS_STR_FOR_ERRORID);
        end

        function values = processMultiValues(~, values)
            if ~iscell(values)
                error(message('MATLAB:mapreduceio:keyvalueprocessor:nonCellMultiValue'));
            end
        end

        function input = processMultiNumericScalarsOrStrings(~, input, keysOrValuesStr)
            if ~iscell(input)
                input = iProcessNonCellMultiNumericScalarsOrStrings(input, keysOrValuesStr);
            else
                input = iProcessCellMultiNumericScalarsOrStrings(input, keysOrValuesStr);
            end
        end
    end

    methods (Access = public, Hidden = true)
        function setStoreKeyType(kvp, sampleKey)
            %setStoreKeyType(kvp, sampleKey)
            % Set the KeyType property to the sampleKey's data type.
            kvp.KeyType = class(sampleKey);
        end

        function key = processSingleKey(kvp, key)
            %processSingleKey
            % Check if keys are either a string or a numeric scalar. A
            % single key cannot be a cell or a numeric vector.
            import matlab.mapreduce.internal.KeyValueProcessor;
            import matlab.mapreduce.internal.isNonSingle;
            if isNonSingle(key, KeyValueProcessor.KEYS_STR_FOR_ERRORID)
                error(message('MATLAB:mapreduceio:keyvalueprocessor:nonSingleKey'));
            end
            if ischar(key)
                key = {key};
            end
            checkHomogeneousKey(kvp, key);
        end

        function value = processSingleValue(~, value)
            %processSingleValue
            % Values can be of any type and they are concatenated using a
            % cell array.
            value = {value};
        end

        function [keys, values, empty] = processMultiKeysValues(kvp, keys, values)
            % Process keys
            keys = processMultiKeys(kvp, keys);
            % Process values
            values = processMultiValues(kvp, values);
            empty = isempty(keys) && isempty(values);
            if numel(keys) ~= numel(values)
                error(message('MATLAB:mapreduceio:keyvalueprocessor:nonEqualNumKeysValues'));
            elseif empty
                return;
            end
            % We store keys and values as column vectors
            keys = keys(:);
            values = values(:);
            % Check for homogeneity
            checkHomogeneousKey(kvp, keys);
        end
    end % methods end

end % classdef end


function input = iProcessCellMultiNumericScalarsOrStrings(input, keysOrValuesStr)
import matlab.mapreduce.internal.validateLogicalAndNumeric;
if iIsCellScalarNumericLogical(input, keysOrValuesStr)
    try
        input = cell2mat(input);
    catch e
        if strcmp(e.identifier, 'MATLAB:cell2mat:MixedDataTypes')
            error(message('MATLAB:mapreduceio:keyvalueprocessor:nonCellStrNonNumVec',...
                keysOrValuesStr));
        else
            throw(e)
        end
    end
elseif ~matlab.io.internal.validators.isCellOfStrings(input)
    error(message('MATLAB:mapreduceio:keyvalueprocessor:nonCellStrNonNumVec', keysOrValuesStr));
end
end

function input = iProcessNonCellMultiNumericScalarsOrStrings(input, keysOrValuesStr)
import matlab.mapreduce.internal.validateLogicalAndNumeric;
if matlab.io.internal.validators.isString(input)
    input = {input};
elseif ~((isequal(input, []) || isvector(input)) && validateLogicalAndNumeric(input, keysOrValuesStr))
    keysOrValuesStr = lower(keysOrValuesStr);
    error(message('MATLAB:mapreduceio:keyvalueprocessor:nonStrNonNumVec', keysOrValuesStr(1:end-1), keysOrValuesStr));
end
end

% Faster than
%  all(cellfun(@(x) isscalar(x) && ...
%      validateLogicalAndNumeric(x, keysOrValuesStr), input))
function tf = iIsCellScalarNumericLogical(cellInput, keysOrValuesStr)
import matlab.mapreduce.internal.validateLogicalAndNumeric;
tf = false;
for ii=1:numel(cellInput)
    item = cellInput{ii};
    if ~(isscalar(item) && validateLogicalAndNumeric(item, keysOrValuesStr))
        return;
    end
end
tf = true;
end
