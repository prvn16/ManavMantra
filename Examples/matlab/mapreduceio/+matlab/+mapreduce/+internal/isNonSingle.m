function tf = isNonSingle(input, keysOrValuesStr)
%ISNONSINGLE Checks if the input is non single
%   Used in matlab.mapreduce.internal.KeyValueProcessor.
%   This is to see if the user is actually adding single key or single value
%   using the add() method. add() method does not take a cell single key. It
%   does not take single value, when adding to text output.
%
%   See also datastore, mapreduce.

%   Copyright 2014-2016 The MathWorks, Inc.
import matlab.mapreduce.internal.validateLogicalAndNumeric;
tf = iscell(input) || (~matlab.io.internal.validators.isString(input) &&...
                    ~(isscalar(input) && validateLogicalAndNumeric(input, keysOrValuesStr)));
end
