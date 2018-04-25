function insert(type_id, name, offset, member_datatype)
%H5T.insert  Add member to compound datatype.
%   H5T.insert(type_id, name, offset, member_datatype) adds another member to the
%   compound datatype specified by type_id. name is a text string that
%   specifies the name of the new member, which must be unique in the
%   compound datatype. offset specifies where you want to insert the new
%   member and member_datatype specifies the datatype identifier of the new
%   member.
%
%   Example:
%       type_id = H5T.create('H5T_COMPOUND',16);
%       H5T.insert(type_id,'first',0,'H5T_NATIVE_DOUBLE');
%       H5T.insert(type_id,'second',8,'H5T_NATIVE_INT');
%       H5T.insert(type_id,'third',12,'H5T_NATIVE_UINT');
%
%   See also H5T, H5T.create.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Tinsert', type_id, name, offset, member_datatype); 
