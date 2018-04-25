function addPreConstructorFunction(hThis, varargin)

% Copyright 2003-2015 The MathWorks, Inc.

hFunc = createFunction(varargin{:});

hFuncList = get(hThis,'PreConstructorFunctions');
hFuncList = [hFuncList,hFunc];
set(hThis,'PreConstructorFunctions',hFuncList);
