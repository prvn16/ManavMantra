function addSubFunction(hCodeProgram,hSubFunc)
% Add a unique subfunction to the list of subfunctions

% Copyright 2006 The MathWorks, Inc.

subFuncList = hCodeProgram.SubFunctionList;
if all(subFuncList ~= hSubFunc)
    hCodeProgram.SubFunctionList = [subFuncList hSubFunc];
    set(hSubFunc,'ParentRef',hCodeProgram);
end