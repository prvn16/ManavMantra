function uniqueID = getParentIdentifier(this, sysObj)
% The parent property should match with the
% identifier generation. For example,
% identifiers retain the new line characters in
% the name and hence the parent string should
% also retain the new line characters in the
% string. This will help resolve it to the
% Simulink entity when needed.

%   Copyright 2017 The MathWorks, Inc.

if isa(sysObj, 'Simulink.BlockDiagram')
    uniqueID = 'FPTRoot';
else
    parentObj = sysObj.getParent;
    uniqueID = this.getIdentifierObject(parentObj);
    uniqueID = uniqueID.UniqueKey;
end
end
