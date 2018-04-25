function tf = isUniformRead(ds)
%isPartitionable Compatibility layer for checking if the output of read is
% vertically concatenable.

%   Copyright 2017 The MathWorks, Inc.

if matlab.io.datastore.internal.shim.isV1ApiDatastore(ds)
    tf = isa(ds, 'matlab.io.datastore.TabularDatastore') ...
        || isa(ds, 'matlab.io.datastore.TallDatastore') ...
        || (isa(ds, 'matlab.io.datastore.FileDatastore') ...
            && isprop(ds, 'UniformRead') && ds.UniformRead);
else
    % In API v2, all of read, readall and preview currently must return
    % vertically concatenable data.
    tf = true;
end
