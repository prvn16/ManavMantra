function [map, hierarchyStruct] = regenerateOnEntireTable(this, scopingTable)
% REGENERATEONENTIRETABLE Re-create the map and hierarchy based on the entire scoping
% table for a change in run name.

% Copyright 2016-2017 The MathWorks, Inc.

[map, hierarchyStruct] = generateMappingForTable(this, scopingTable);
end
