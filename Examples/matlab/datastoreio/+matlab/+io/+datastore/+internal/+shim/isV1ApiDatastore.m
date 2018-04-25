function tf = isV1ApiDatastore(ds)
%isV1ApiDatastore Check if the datastore follows the V1 API

%   Copyright 2017 The MathWorks, Inc.

tf = isa(ds, 'matlab.io.datastore.Datastore');
