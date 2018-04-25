function offset = get_offset(dataset_id)
%H5D.get_offset  Return location of dataset in file.
%   offset = H5D.get_offset(dataset_id) returns the location in the file of
%   the dataset specified by dataset_id. The location is expressed as an
%   offset, in bytes, from the beginning of the file.
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g1/g1.1/dset1.1.1');
%       offset = H5D.get_offset(dset_id);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5D.

%   Copyright 2006-2013 The MathWorks, Inc.

offset = H5ML.hdf5lib2('H5Dget_offset', dataset_id);            
