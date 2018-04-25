function toText(hRoutine,hFunctionTable,options)
% Determines text representation

% Copyright 2006 The MathWorks, Inc.

hVariableTable = hRoutine.VariableTable;

% Go through the input arguments
hInputArgs = get(hRoutine,'Argin');
for i = 1:length(hInputArgs)
    if isa(hInputArgs{i},'codegen.codeargument')
        hInputArgs{i}.toText(hVariableTable);
    end
end

% Go through the function list, building up
hFuncList = get(hRoutine,'Functions');
n_funcs = length(hFuncList);
for n = n_funcs:-1:1
    hFuncList(n).toText(hVariableTable);
end

% Go through the output arguments
hOutputArgs = get(hRoutine,'Argout');
for i = 1:length(hOutputArgs)
    if isa(hOutputArgs{i},'codegen.codeargument');
        hOutputArgs{i}.toText(hVariableTable);
    end
end

% Recurse down to the subfunctions
hSubFunctions = get(hRoutine,'SubFunctionList');

for n = 1:length(hSubFunctions)
   % Recursion
   hFunctionTable.addFunction(hSubFunctions(n));
   hSubFunctions(n).toText(hFunctionTable);
end