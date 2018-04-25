function tf = isReadEncellified(ds)
%isPartitionable Compatibility layer for checking if read has already
% encellified non-uniform data.

%   Copyright 2017 The MathWorks, Inc.

if matlab.io.datastore.internal.shim.isV1ApiDatastore(ds)
    % if non-uniform data, only ImageDatastore can encellify
    % read data when ReadSize > 1.
    tf = ~matlab.io.datastore.internal.shim.isUniformRead(ds) && ...
        isa(ds, 'matlab.io.datastore.ImageDatastore') && ...
        isprop(ds, 'ReadSize') && isnumeric(ds.ReadSize) && ...
        ds.ReadSize > 1;
else
    % In API v2, all of read, readall and preview currently must return
    % vertically concatenable data.
    tf = false;
end
