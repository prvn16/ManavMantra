function uniqueID = getIdentifierObject(this, sysObj)
% GETIDENTIFIER returns the unique ID object for the system

% Copyright 2017 The MathWorks, Inc.

if strncmp(class(sysObj), 'Stateflow', 8)
    blkID = num2str(sysObj.Id);
else
    blkID = num2str(sysObj.Handle);
end
uniqueID =  fxptds.Utils.getSubsystemIdUsingBlkObj(sysObj, blkID);
this.UniqueIDMap(blkID) = 1;
