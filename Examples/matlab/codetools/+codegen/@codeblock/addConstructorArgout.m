function addConstructorArgout(hThis,hArgout)

% Copyright 2003-2006 The MathWorks, Inc.

hFunc = getConstructor(hThis);
addArgout(hFunc,hArgout);