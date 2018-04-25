function resultSet = getResultSetForIDs(this, ids)
% GETRESULTSETFORIDS Combine all the result Ids for the subsystem Ids into
% one array and return.

% Copyright 2016-2017 The MathWorks, Inc.

resultSet = {};
for i = 1:numel(ids)
    id = ids{i};
    if this.ResultScopingMap.isKey(id)
        resultSet = [resultSet, this.ResultScopingMap(id)]; %#ok<AGROW>
    end
end
end
