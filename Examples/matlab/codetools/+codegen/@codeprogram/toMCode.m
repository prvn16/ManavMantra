function out = toMCode(hCodeProgram,options)
% Generates code based on input codeprogram object

% Copyright 2006-2007 The MathWorks, Inc.

% Traverse code block tree and convert various datatypes within code block
% objects into text representation. Note that we are not creating another
% tree here, but just converting all datatypes into text. For example, a
% matrix instance will be converted into a text representation such
% as "[3, 4, 2]". A variable table is used here to keep track of
% variables names and their mapping to actual datatypes.

hSubFuncList = hCodeProgram.SubFunctionList;
for i = 1:length(hSubFuncList)
    hCodeProgram.FunctionTable.addFunction(hSubFuncList(i));
    hSubFuncList(i).toText(hCodeProgram.FunctionTable,options.OutputTopNode);
end
notify(hCodeProgram,'TextComplete');

% Buffer used to store final text representation of code
hText = codegen.stringbuffer;

% Traverse hierarchy and add code to the codegen.stringbuffer
if ~isempty(hSubFuncList)
    hSubFuncList(1).toMCode(hText,options,true)
end
for i = 2:length(hSubFuncList)
    hSubFuncList(i).toMCode(hText,options,false);
end

out = get(hText,'Text');
