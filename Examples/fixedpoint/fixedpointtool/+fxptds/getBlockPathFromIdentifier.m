function [sysPath, sysObj] = getBlockPathFromIdentifier(identifierString,classOfIdentifier)
% GETBLOCKPATHFROMIDENTIFIER Converts the hex uniqueID string that is
% returned by fxptds.AbstractIdentifier children to a block path that is
% resolved in Simulink.

% This function is used by FxD web clients to resolve IDs to block paths.

% Copyright 2015-2016 The MathWorks, Inc.

% This only handles Stateflow & Simulink at this point. Need to enhance it
% to resolve MATLAB unique IDs if needed.

sysPath = '';
sysObj = [];
idx = strfind(identifierString, '::');
systemID = identifierString;
if ~isempty(idx)
    systemID = identifierString(1:idx-1);
end
if ~strncmpi(classOfIdentifier,'Stateflow',9)
    system = get_param(hex2num(systemID),'Object');   
else
    sfObj = find(sfroot, 'Id',hex2num(systemID));
    if ~fxptds.isStateflowChartObject(sfObj)
        % Get the wrapping subsystem object
        system = sfObj;
    else
        system = sfObj.up;
    end
end
if ~isempty(system)
    sysPath = system.getFullName;
    sysObj = system;
end
