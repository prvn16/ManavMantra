function close(dataset_id)
%H5D.close  Close dataset.
%   H5D.close(dataset_id) ends access to a dataset specified by dataset_id 
%   and releases resources used by it.
%
%   See also H5D, H5D.create, H5D.open.

%   Copyright 2006-2013 The MathWorks, Inc.

if isa(dataset_id, 'H5ML.id')
    id = dataset_id.identifier;
    dataset_id.identifier = -1;
else
    id = dataset_id;
end
H5ML.hdf5lib2('H5Dclose', id);            
