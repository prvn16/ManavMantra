function hFunc = findSubFunction(hRoutine,funcName)
% Find a sub function with a given in the current hierarchy leading to this
% leaf.

% Copyright 2006 The MathWorks, Inc.

% First, see if any currently registered subfunctions match.
hFunc = [];
hSubFunctions = hRoutine.SubFunctionList;
for i = 1:length(hSubFunctions)
    if strcmpi(hSubFunctions(i).Name,funcName)
        hFunc = hSubFunctions(i);
        break;
    end
end