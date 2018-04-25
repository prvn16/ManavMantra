function type_id = get_type(dataset_id)
%H5D.get_type  Return copy of datatype.
%   type_id = H5D.get_type(dataset_id) returns an identifier for a copy of 
%   the datatype for the dataset specified by dataset_id.
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g1/g1.1/dset1.1.1');
%       type_id = H5D.get_type(dset_id);
%       H5T.close(type_id);
%       H5D.close(dset_id);
%       H5F.close(fid);
% 
%   See also H5D, H5T.close.

%   Copyright 2006-2013 The MathWorks, Inc.


type_id = H5ML.hdf5lib2('H5Dget_type', dataset_id);            
type_id = H5ML.id(type_id,'H5Tclose');
