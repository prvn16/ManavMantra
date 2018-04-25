function output = get_tag(type_id)
%H5T.get_tag  Return tag associated with opaque datatype.
%   tag = H5T.get_tag(type_id) returns the tag associated with the opaque
%   datatype specified by type_id.
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/opaque');
%       dtype_id = H5D.get_type(dset_id);
%       tag = H5T.get_tag(dtype_id);
%
%   See also H5T, H5T.set_tag.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Tget_tag',type_id); 
