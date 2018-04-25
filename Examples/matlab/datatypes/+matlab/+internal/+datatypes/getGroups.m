function grprows = getGroups(group,numgroups)
%GETGROUPS get cell array containing row indices for each group.

%   Copyright 2014 The MathWorks, Inc.

[sgroup,sgidx] = sort(group); % presort so accumarray doesn't have to
nonNaN = ~isnan(sgroup);

if isempty(sgroup) || ~any(nonNaN)
    grprows = cell(numgroups,1);
else
    grprows = accumarray(sgroup(nonNaN),sgidx(nonNaN),[numgroups,1],@(x){x});
end
