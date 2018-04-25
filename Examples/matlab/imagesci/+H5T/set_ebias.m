function set_ebias(type_id, ebias)
%H5T.set_ebias  Set exponent bias of floating-point datatype.
%   H5T.set_ebias(type_id, ebias) sets the exponent bias of a
%   floating-point type. type_id is a datatype identifier. ebias is an
%   exponent bias value.
%
%   Example:
%       type_id = H5T.copy('H5T_NATIVE_FLOAT');
%       H5T.set_size(type_id,32);
%       H5T.set_ebias(type_id,99);
%
%   See also H5T, H5T.get_ebias.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Tset_ebias',type_id, ebias); 
