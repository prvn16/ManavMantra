function [hFunc] = getConstructor(hThis)

% Copyright 2003-2004 The MathWorks, Inc.

% Get handles
hFunc = get(hThis,'Constructor');

% Create constructor object if necessary
if isempty(hFunc) || ~isobject(hFunc)
  hMomento = get(hThis,'MomentoRef');
  hObj = get(hMomento,'ObjectRef');
  classname = class(hObj);
  hFunc = codegen.codefunction('CodeRef',hThis,'Name',classname);
  set(hThis,'Constructor',hFunc);
end