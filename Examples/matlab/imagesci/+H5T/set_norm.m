function set_norm(type_id, norm)
%H5T.set_norm  Set mantissa normalization of floating-pint datatype.
%   H5T.set_norm(type_id, norm) sets the mantissa normalization of a
%   floating-point datatype. Valid normalization types are:
%   H5T_NORM_IMPLIED, H5T_NORM_MSBSET, or H5T_NORM_NONE.
%
%   Example:
%       type_id = H5T.copy('H5T_NATIVE_FLOAT');
%       norm_type = H5ML.get_constant_value('H5T_NORM_MSBSET');
%       H5T.set_norm(type_id,norm_type);
%
%   See also H5T, H5T.get_norm.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Tset_norm',type_id, norm); 
