function hProp = getProperty(hThis,propname)
% Returns the property object for specified by "propname"

% Copyright 2007-2012 The MathWorks, Inc.

% Only take strings
if ~ischar(propname)
    error(message('MATLAB:codetools:codegen:InvalidInputStringRequired'));
end

% Get handles
hMomento = get(hThis,'MomentoRef');

hPropList = get(hMomento,'PropertyObjects');
hProp = find(hPropList,'Name',propname,'Ignore',false);


