function addFunction(hThis,hFunc)

% Copyright 2006 The MathWorks, Inc.

hFuncList = get(hThis,'Functions');
hFuncList = [hFuncList,hFunc];
set(hThis,'Functions',hFuncList);