function set_strpad(type_id, strpad)
%H5T.set_strpad  Set storage mechanism for string datatype.
%   H5T.set_strpad(type_id, storage_type) defines the storage mechanism for
%   the string datatype identified by type_id.  The storage type may be one
%   of the following values:
%
%       'H5T_STR_NULLTERM' - null terminated
%       'H5T_STR_NULLPAD'  - padded with zeros
%       'H5T_STR_SPACEPAD' - padded with spaces
%
%   Example:  create a ten-character string datatype with space padding.
%       type_id = H5T.copy('H5T_C_S1');
%       H5T.set_size(type_id,10);
%       H5T.set_strpad(type_id,'H5T_STR_SPACEPAD');
%
%   See also H5T, H5T.get_strpad.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Tset_strpad',type_id, strpad); 
