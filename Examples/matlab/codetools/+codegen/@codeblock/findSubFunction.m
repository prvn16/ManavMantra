function hFunc = findSubFunction(hCode,funcName)
% Find a sub function with a given in the current leaf and its ancestors
% leading to this leaf.

% Copyright 2006 The MathWorks, Inc.

% First, see if any currently registered subfunctions match.
hFunc = [];
hSubFunctions = hCode.SubFunctionList;
for i = 1:length(hSubFunctions)
    if strcmpi(hSubFunctions(i).Name,funcName)
        hFunc = hSubFunctions(i);
        break;
    end
end
if isempty(hFunc)
    par = up(hCode);
    if ~isempty(par)
        hFunc = findSubFunction(par,funcName);
    end
end
