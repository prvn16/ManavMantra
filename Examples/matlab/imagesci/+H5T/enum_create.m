function output = enum_create(parent_id)
%H5T.enum_create  Create new enumeration datatype.
%   output = H5T.enum_create(parent_id) creates a new enumeration datatype
%   based on the specified base datatype, parent_id, which must be an
%   integer type. output is a datatype identifier for the new enumeration
%   datatype.
%   
%   Example:
%       parent_id = H5T.copy('H5T_NATIVE_UINT');
%       type_id = H5T.enum_create(parent_id);
%       H5T.enum_insert(type_id,'red',1);
%       H5T.enum_insert(type_id,'green',2);
%       H5T.enum_insert(type_id,'blue',3);
%       H5T.close(type_id);
%       H5T.close(parent_id);
%
%   See also H5T, H5T.enum_insert.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Tenum_create',parent_id); 
output = H5ML.id(output,'H5Tclose');
