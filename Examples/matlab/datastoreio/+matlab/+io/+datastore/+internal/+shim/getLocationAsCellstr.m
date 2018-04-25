function location = getLocationAsCellstr(ds)
%getLocationAsCellStr Compatibility layer for accessing
% HadoopFileBased/getLocation as a cell array of location character vectors.

%   Copyright 2017 The MathWorks, Inc.

location = matlab.io.datastore.internal.shim.getLocation(ds);
location = matlab.io.datastore.internal.getFileNamesFromFileSet(location);
