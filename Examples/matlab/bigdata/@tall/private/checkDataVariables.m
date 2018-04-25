function dataVars = checkDataVariables(tX, dataVars, fcnName)
%checkDataVariables - Validate 'DataVariables' value against tall input tX

% Copyright 2017 The MathWorks, Inc.

inputClass = tX.Adaptor.Class;
inputIsTabular = any(strcmpi(inputClass, {'table', 'timetable'}));

if ~inputIsTabular
    error(message(['MATLAB:' fcnName ':DataVariablesArray']));
end

if isa(dataVars, 'function_handle')
    % TODO g1553956: Add support for function_handle input to rmmissing &
    % fillmissing
    error(message('MATLAB:bigdata:array:UnsupportedDataVarsFcn'));
end

if isnumeric(dataVars) && ~isreal(dataVars)
    % tabular/subsref allows complex(1) for paren and braces, but not dot.
    % Use colon to slice off any zero complex component
    dataVars = dataVars(:);
end

varNames = subsref(tX, substruct('.', 'Properties', '.', 'VariableNames'));

try
    [~, dataVars] = matlab.bigdata.internal.util.resolveTableVarSubscript(varNames, dataVars);
    dataVars = unique(dataVars);
catch
    error(message(['MATLAB:' fcnName ':DataVariablesTableSubscript']));
end
end