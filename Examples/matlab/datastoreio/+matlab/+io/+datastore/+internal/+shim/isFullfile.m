function tf = isFullfile(ds)
%isFullfile Compatibility layer for accessing HadoopFileBased/isfullfile

%   Copyright 2017 The MathWorks, Inc.

if matlab.io.datastore.internal.shim.isV1ApiDatastore(ds)
    tf = ds.areSplitsWholeFile();
else
    tf = ds.isfullfile();
end
