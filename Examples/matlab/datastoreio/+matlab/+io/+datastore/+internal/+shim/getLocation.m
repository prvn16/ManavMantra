function location = getLocation(ds)
%getLocation Compatibility layer for accessing HadoopFileBased/getLocation

%   Copyright 2017 The MathWorks, Inc.

if matlab.io.datastore.internal.shim.isV1ApiDatastore(ds)
    if ~ds.areSplitsOverCompleteFiles()
        error(message('MATLAB:datastoreio:datastore:partitionUnsupportedOnHadoop'));
    end
    location = ds.Files;
else
    location = ds.getLocation();
end
