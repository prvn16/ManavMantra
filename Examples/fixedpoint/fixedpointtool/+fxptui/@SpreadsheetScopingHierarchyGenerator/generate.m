function [map, hierarchyStruct] = generate(this, scopingTable)
% GENERATE Generate the subsystem ID to result mapping to aid scoping of
% results in the UI.

% Copyright 2016-2017 The MathWorks, Inc.

if isempty(this.TreeHierarchyCache)
    this.TreeHierarchyCache = this.TreeData.generateMapping;
end
[map, hierarchyStruct] = generateMappingForTable(this, scopingTable);
if ~isempty(this.InitialHiearchyFound)
    hierarchyStruct = [hierarchyStruct this.InitialHiearchyFound];
    % Wipe out the initial hierarchy change detected after
    % capturing it
    this.InitialHiearchyFound = struct([]);
end
end
