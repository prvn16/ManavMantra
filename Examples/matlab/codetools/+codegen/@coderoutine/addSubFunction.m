function addSubFunction(hCodeRoutine,hSubFunc)
% Add a unique subfunction to the list of subfunctions

% Copyright 2006 The MathWorks, Inc.

subFuncList = hCodeRoutine.SubFunctionList;
if all(subFuncList ~= hSubFunc)
    hCodeRoutine.SubFunctionList = [subFuncList hSubFunc];
    set(hSubFunc,'ParentRef',hCodeRoutine);
end