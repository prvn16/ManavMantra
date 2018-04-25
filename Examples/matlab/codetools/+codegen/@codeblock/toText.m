function toText(hCode,hVariableTable,hFunctionTable)
% Determines text representation

% Copyright 2006-2015 The MathWorks, Inc.

% Pre-Constructor Functions
hFuncList = get(hCode,'PreConstructorFunctions');
n_funcs = length(hFuncList);
for n = 1:n_funcs
    hFuncList(n).toText(hVariableTable);
end

% Constructor
hConstructor = get(hCode,'Constructor');
if ~isempty(hConstructor)
    hConstructor.toText(hVariableTable);
end

% Post-Constructor Functions
hFuncList = get(hCode,'PostConstructorFunctions');
n_funcs = length(hFuncList);
for n = 1:n_funcs
    hFuncList(n).toText(hVariableTable);
end

% Get children first
syntax_kids = findobj(hCode,'-depth',1);

% First kid is always self, so ignore index 1
for n = 2:length(syntax_kids)
   % Recursion
   syntax_kids(n).toText(hVariableTable,hFunctionTable);
end

% Post-Child Functions
hFuncList = get(hCode,'PostChildFunctions');
n_funcs = length(hFuncList);
for n = 1:n_funcs
    hFuncList(n).toText(hVariableTable);
end

% Recurse down to the subfunctions
hSubFunctions = get(hCode,'SubFunctionList');

for n = 1:length(hSubFunctions)
   % Recursion
   hFunctionTable.addFunction(hSubFunctions(n));
   hSubFunctions(n).toText(hFunctionTable);
end
