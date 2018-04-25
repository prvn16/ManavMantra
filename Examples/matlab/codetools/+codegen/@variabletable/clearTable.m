function clearTable(hVariableTable)
% Clear the variable table

% Copyright 2006 The MathWorks, Inc.

hVariableTable.VariableList = [];
hVariableTable.ParameterList = [];
hVariableTable.VariableNameList = cell(0);
hVariableTable.VariableNameListCount = [];