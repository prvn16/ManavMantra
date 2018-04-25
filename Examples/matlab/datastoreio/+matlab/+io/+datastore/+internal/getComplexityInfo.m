function [hasComplexVariables, complexVariables] = getComplexityInfo(data)
% Check if the data is complex. For tabular types, this will recurse into
% table variables.
%
% This is used by TallDatastore to ensure chunked complex data remains
% complex throughout the entire dataset.

%   Copyright 2017 The MathWorks, Inc.

if isnumeric(data)
    hasComplexVariables = ~isreal(data);
    complexVariables = {hasComplexVariables};
elseif istable(data) || istimetable(data)
    % TODO(g1580766): This is an internal API of table and should be
    % replaced by the official API table2struct(chunk,'ToScalar',true).
    % This code uses the internal version as the official API is an order
    % of magnitude slower.
    vars = struct2cell(getVars(data))';
    [hasComplexVariables, complexVariables] ...
        = cellfun(@matlab.io.datastore.internal.getComplexityInfo, vars);
    hasComplexVariables = any(hasComplexVariables);
    complexVariables = {complexVariables};
else
    hasComplexVariables = false;
    complexVariables = {false};
end
end
