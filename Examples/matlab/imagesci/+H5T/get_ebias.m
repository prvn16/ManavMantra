function output = get_ebias(type_id)
%H5T.get_ebias  Return exponent bias of floating point type.
%   output = H5T.get_ebias(type_id) returns the exponent bias of a 
%   floating-point type. type_id is datatype identifier.
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/float');
%       type_id = H5D.get_type(dset_id);
%       ebias = H5T.get_ebias(type_id);
%
%   See also H5T, H5T.set_ebias.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Tget_ebias',type_id); 
