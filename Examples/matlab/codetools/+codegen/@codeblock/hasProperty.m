function [bool] = hasProperty(hThis,propname)
% Return true is recorded by code object

% Copyright 2003-2012 The MathWorks, Inc.

bool = false;

% Only take strings
if ~ischar(propname)
    error(message('MATLAB:codetools:codegen:InvalidInputStringRequired'));
end

% Get handles
hMomento = get(hThis,'MomentoRef');

hPropList = get(hMomento,'PropertyObjects');
bool = ~isempty(findobj(hPropList,'Name',propname,'Ignore',false));


