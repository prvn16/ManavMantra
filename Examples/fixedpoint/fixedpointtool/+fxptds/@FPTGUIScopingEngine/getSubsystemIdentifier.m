function uniqueIdentifier = getSubsystemIdentifier(this, id)
%% GETSUBSYSTEMIDENTIFIER function queries the SubsystemIDMap for a given id
% and retrieves the subsystemIdentifier that maps to the id

%   Copyright 2017 The MathWorks, Inc.

    uniqueIdentifier = [];
    if this.SubsystemIDMap.isKey(id)
        uniqueIdentifier = this.SubsystemIDMap(id);
    end
end
