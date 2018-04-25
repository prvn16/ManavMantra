function vlen_type_id = vlen_create(base_id)
%H5T.vlen_create  Create new variable-length datatype.
%   vlen_type_id = H5T.vlen_create(base_id) creates a new variable-length
%   (VL) datatype. base_id specifies the base type of the datatype to
%   create.
%
%   Example:  create a variable length datatype for 64-bit floating point
%   numbers.
%       base_type_id = H5T.copy('H5T_NATIVE_DOUBLE');
%       vlen_type_id = H5T.vlen_create(base_type_id);
%
%   See also H5T, H5T.is_variable_str.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Tvlen_create',base_id); 
vlen_type_id = H5ML.id(output,'H5Tclose');
