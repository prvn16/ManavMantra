function super_type_id = get_super(type_id)
%H5T.get_super  Return bad datatype.
%   super_type_id = H5T.get_super(type_id) returns the base datatype from
%   which the datatype type specified by type_id is derived.
%
%   Example:  retrieve the base datatype for an enumerated dataset.
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/enum');
%       dtype_id = H5D.get_type(dset_id);
%       super_type_id = H5T.get_super(dtype_id);
%
%   See also H5T.

%   Copyright 2006-2013 The MathWorks, Inc.

raw_super_type_id = H5ML.hdf5lib2('H5Tget_super',type_id); 
super_type_id = H5ML.id(raw_super_type_id,'H5Tclose');
