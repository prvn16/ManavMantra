function addPostConstructorFunction(hThis, varargin)

% Copyright 2003-2015 The MathWorks, Inc.

hFunc = createFunction(varargin{:});

hFuncList = get(hThis,'PostConstructorFunctions');
hFuncList = [hFuncList,hFunc];
set(hThis,'PostConstructorFunctions',hFuncList);
