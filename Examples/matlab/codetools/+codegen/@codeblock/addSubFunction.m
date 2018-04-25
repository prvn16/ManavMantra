function addSubFunction(hCode,hSubFunc)
% Add a unique subfunction to the list of subfunctions

% Copyright 2006 The MathWorks, Inc.

subFuncList = hCode.SubFunctionList;
if all(subFuncList ~= hSubFunc)
    hCode.SubFunctionList = [subFuncList hSubFunc];
    set(hSubFunc,'ParentRef',hCode);
end