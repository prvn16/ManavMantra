function hFunc = findSubFunction(hCodeTree,funcName)
% Find a sub function with a given in the current hierarchy leading to this
% leaf.

% Copyright 2006 The MathWorks, Inc.

% First, see if any currently registered subfunctions match.
hFunc = [];
hFunc = findSubFunction(hCodeTree.CodeRoot,funcName);
if isempty(hFunc)
    par = get(hRoutine,'ParentRef');
    if ~isempty(par)
        hFunc = findSubFunction(par,funcName);
    end
end