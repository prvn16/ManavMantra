function tf = validateLogicalAndNumeric(x, keysOrValuesStr)
%VALIDATENUMERICSUPPORT Checks for a supported numeric input.
%   Used in matlab.mapreduce.internal.KeyValueProcessor. This is to
%   validate if the user is adding supported numeric (non-NaN, non-sparse,
%   non-complex) key types.
%
%   See also datastore, mapreduce.

%   Copyright 2014 The MathWorks, Inc.
tf = false;
if islogical(x)
    iErrorLogicalNonNumericSupport(keysOrValuesStr, 'logicalUnSupported');
elseif isnumeric(x)
    if ~isreal(x)
        iErrorLogicalNonNumericSupport(keysOrValuesStr, 'numericNonReal');
    elseif issparse(x)
        iErrorLogicalNonNumericSupport(keysOrValuesStr, 'numericSparse');
    elseif isAnyNaN(x)
        iErrorLogicalNonNumericSupport(keysOrValuesStr, 'numericNaN');
    end
    tf = true;
end
end

% Bit faster than any(isnan(x))
function tf = isAnyNaN(input)
    tf = false;
    for ii = 1:numel(input)
        if isnan(input(ii))
            tf = true;
            return;
        end
    end
end

function iErrorLogicalNonNumericSupport(keysOrValuesStr, msgIDCatStr)
if strcmpi('Keys', keysOrValuesStr)
    msgID = ['MATLAB:mapreduceio:keyvalueprocessor:' msgIDCatStr];
else
    msgID = ['MATLAB:mapreduceio:textkeyvalueprocessor:' msgIDCatStr];
end
error(message(msgID));
end
