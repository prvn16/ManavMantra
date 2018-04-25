function initializeDatastore(ds, splitinfo)
%initializeDatastore Compatibility layer for accessing HadoopFileBased/initializeDatastore

%   Copyright 2017 The MathWorks, Inc.

if matlab.io.datastore.internal.shim.isV1ApiDatastore(ds)
    ds.initFromHadoopSplit(splitinfo);
else
    [hadoopInfo.FileName,hadoopInfo.Offset,hadoopInfo.Size] = ...
        matlab.io.datastore.internal.getHadoopInfoFromSplit(splitinfo);
    ds.initializeDatastore(hadoopInfo);
end
