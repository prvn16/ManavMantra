function set_sign(type_id, sgn)
%H5T.set_sign  Set sign property for integer datatype.
%   H5T.set_sign(type_id, sign) sets the sign property for an integer type. 
%   type_id is a datatype identifier. sign specifies the sign type. Valid
%   values are H5T_SGN_NONE or H5T_SGN_2.
%
%   Example:
%       type_id = H5T.copy('H5T_NATIVE_LONG');
%       sgn = H5ML.get_constant_value('H5T_SGN_NONE');
%       H5T.set_sign(type_id,sgn);
%
%   See also H5T, H5T.get_sign.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Tset_sign',type_id,sgn); 
