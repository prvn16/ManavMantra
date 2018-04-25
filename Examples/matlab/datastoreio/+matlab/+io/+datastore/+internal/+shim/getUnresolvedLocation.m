function location = getUnresolvedLocation(ds)
%getUnresolvedLocation Compatibility layer for accessing the unresolved
%location paths of a datastore as a cellstr.

%   Copyright 2017 The MathWorks, Inc.

if matlab.io.datastore.internal.shim.isV1ApiDatastore(ds)
    if ~ds.areSplitsOverCompleteFiles()
        error(message('MATLAB:datastoreio:datastore:partitionUnsupportedOnHadoop'));
    end
    if isa(ds, 'matlab.io.datastore.ImageDatastore') ...
            || isa(ds, 'matlab.io.datastore.FileDatastore') ...
            || isa(ds, 'matlab.io.datastore.MatSeqDatastore') ...
            || isa(ds, 'matlab.io.datastore.TabularTextDatastore')
        location = ds.getUnresolvedFiles();
    else
        location = ds.Files;
    end
else
    location = matlab.io.datastore.internal.shim.getLocation(ds);
    location = matlab.io.datastore.internal.getFileNamesFromFileSet(location);
end
