function res = canRemove(hArg,hFunc)
% Given a function, return whether the variable can be removed within the
% context of this function. If the function is not registered, the result
% will be false.

% Copyright 2006 The MathWorks, Inc.

res = hArg.AllowRemovalList(hArg.FunctionList == hFunc);
if isempty(res)
    res = false;
end
