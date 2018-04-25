function varNames = makeValidVariableNames(varNames,exceptionMode)
%MAKEVALLIDVARIABLENAMES make valid names from variable names.
%   This function takes a cell array of variable names and makes valid and
%   unique strings out of them. It also accepts a mode argument which
%   controls whether it warns when the function makes valid names.

%   Copyright 2016-2017 The MathWorks, Inc.

% local vars
varIndices = 1:numel(varNames);

% trim the variable names for leading or trailing whitespaces
varNames = strtrim(varNames);

% fix up any empty variable names
empties = cellfun('isempty',varNames);
if any(empties)
    varNames(empties) = matlab.internal.tabular.defaultVariableNames(varIndices(empties));
end

% make valid names
varNames = matlab.internal.tabular.private.varNamesDim.makeValidName(varNames, exceptionMode);

% make unique strings
varNames = matlab.lang.makeUniqueStrings(varNames,varIndices,namelengthmax);

% check if they are not reserved names
matlab.internal.tabular.private.varNamesDim.checkReservedNames(varNames);
