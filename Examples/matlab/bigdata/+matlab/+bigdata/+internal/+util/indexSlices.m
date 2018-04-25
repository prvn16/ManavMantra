function data = indexSlices(data, indices)
%indexSlices Helper function for performing indexing only in the first
%dimension.

% Copyright 2016-2017 The MathWorks, Inc.

[hasComplexFields, complexFields] = matlab.io.datastore.internal.getComplexityInfo(data);
sz = size(data);
data = data(indices, :);
if numel(sz) > 2
    data = reshape(data, [size(data, 1), sz(2:end)]);
end
if hasComplexFields
    data = matlab.io.datastore.internal.applyComplexityInfo(data, complexFields);
end
end
