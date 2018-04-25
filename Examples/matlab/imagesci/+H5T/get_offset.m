function output = get_offset(type_id)
%H5T.get_offset  Return bit offset of first significant bit.
%   offset = H5T.get_offset(type_id) returns the offset of the first 
%   significant bit. type_id is a datatype identifier.
%
%    Example:
%        fid = H5F.open('example.h5');
%        dset_id = H5D.open(fid,'/g3/float');
%        type_id = H5D.get_type(dset_id);
%        offset = H5T.get_offset(type_id);
%
%   See also H5T, H5T.set_offset.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Tget_offset',type_id); 
