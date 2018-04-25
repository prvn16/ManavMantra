function out = fieldnames(ts)
%FIELDNAMES  Return a cell array of tscollection property names.
%
%   Names = FIELDNAMES(TSC) returns a cell array of strings containing 
%   the names of the properties of tscollection TSC.

%   Copyright 2004-2008 The MathWorks, Inc. 

% Get public,visibale properties
c = metaclass(ts);
p = c.Properties;
out = {};
for k=1:length(p)
    if ~p{k}.Hidden && strcmp(p{k}.GetAccess,'public')
        out = [out; {p{k}.Name}]; %#ok<AGROW>
    end
end

% Add members
out = [out;gettimeseriesnames(ts)'];