function tf = isDatastore(ds)
%isDatastore Compatibility layer for checking isa datastore.

%   Copyright 2017 The MathWorks, Inc.

tf = matlab.io.datastore.internal.shim.isV1ApiDatastore(ds) ...
    || matlab.io.datastore.internal.shim.isV2ApiDatastore(ds);
