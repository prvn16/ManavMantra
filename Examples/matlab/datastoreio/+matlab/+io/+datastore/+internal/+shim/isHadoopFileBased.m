function tf = isHadoopFileBased(ds)
%isHadoopFileBased Compatibility layer for checking for Hadoop support

%   Copyright 2017 The MathWorks, Inc.

if matlab.io.datastore.internal.shim.isV1ApiDatastore(ds)
    tf = isa(ds, 'matlab.io.datastore.mixin.HadoopFileBasedSupport') ...
        && ~( isa(ds, 'matlab.io.datastore.MatSeqDatastore') && strcmpi(ds.FileType, 'mat') );
elseif isa(ds, 'matlab.io.datastore.internal.FrameworkDatastore')
    tf = ds.IsHadoopFileBased;
else
    tf = isa(ds, 'matlab.io.datastore.HadoopFileBased');
end
