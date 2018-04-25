function data = splitSlices(data, indices)
% Split a chunk of slices into a cell array of smaller chunks using indices
% to mark which cell each slice should be sent.

% Copyright 2017 The MathWorks, Inc.

if istable(data) || istimetable(data)
    data = table(data);
end
[hasComplexVariables, complexVariables] = matlab.io.datastore.internal.getComplexityInfo(data);

if isempty(indices)
    data = cell(0,1);
else
    data = splitapply(@iEncellify, data, indices);
end

if hasComplexVariables
    for ii = 1 : numel(data)
        data{ii} = matlab.io.datastore.internal.applyComplexityInfo(data{ii}, complexVariables);
    end
end
end

function x = iEncellify(x)
x = {x};
end
