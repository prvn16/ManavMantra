function cacheSubsystemIdentifier(this, id, value)
%% CACHESUBSYSTEMIDENTIFIER function stores id-value pair in SubsystemIDMap 

%   Copyright 2017 The MathWorks, Inc.

    this.SubsystemIDMap(id) = value;
end