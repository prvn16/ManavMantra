function tf = isV2ApiDatastore(ds)
%isV2ApiDatastore Check if the datastore follows the V2 API

%   Copyright 2017 The MathWorks, Inc.

tf = isa(ds, 'matlab.io.Datastore');
