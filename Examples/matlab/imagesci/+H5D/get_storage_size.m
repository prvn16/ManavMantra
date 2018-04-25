function dataset_size = get_storage_size(dataset_id)
%H5D.get_storage_size  Determine required storage size.
%   dataset_size = H5D.get_storage_size(dataset_id) returns the amount of 
%   storage that is required for the dataset specified by dataset_id.
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g1/g1.1/dset1.1.1');
%       dataset_size = H5D.get_storage_size(dset_id);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5D.

%   Copyright 2006-2013 The MathWorks, Inc.

dataset_size = H5ML.hdf5lib2('H5Dget_storage_size', dataset_id);            
