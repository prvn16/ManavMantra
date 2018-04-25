function dspace_id = get_space(dataset_id)
%H5D.get_space  Return copy of dataset dataspace.
%   dspace_id = H5D.get_space(dataset_id) returns an identifier for a copy 
%   of the dataspace for a dataset.
%
%   Example:  retrieve the dimensions of an attribute dataspace.
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g1/g1.1/dset1.1.1');
%       space = H5D.get_space(dset_id);
%       [~,dims] = H5S.get_simple_extent_dims(space);
%       H5S.close(space);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5D, H5D.open, H5S.close.

%   Copyright 2006-2013 The MathWorks, Inc.

dspace_id = H5ML.hdf5lib2('H5Dget_space', dataset_id);            
dspace_id = H5ML.id(dspace_id,'H5Sclose');
