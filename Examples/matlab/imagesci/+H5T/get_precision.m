function output = get_precision(type_id)
%H5T.get_precision  Return precision of atomic datatype.
%   output = H5T.get_precision(type_id) returns the precision of an atomic 
%   datatype. type_id is a datatype identifier.
%
%   Example:
%        fid = H5F.open('example.h5');
%        dset_id = H5D.open(fid,'/g3/integer');
%        type_id = H5D.get_type(dset_id);
%        numbits = H5T.get_precision(type_id);
%
%   See also H5T, H5T.set_precision.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Tget_precision',type_id); 
