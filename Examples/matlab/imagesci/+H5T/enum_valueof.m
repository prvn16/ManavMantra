function value = enum_valueof(type_id, name)
%H5T.enum_valueof  Return value of enumeration datatype member.
%   value = H5T.enum_valueof(type_id, member_name) returns the value
%   corresponding to a specified member of an enumeration datatype. type
%   specifies the enumeration datatype and name specifies the member.
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/enum');
%       type_id = H5D.get_type(dset_id);
%       num_members = H5T.get_nmembers(type_id);
%       for j = 1:num_members
%           member_name{j} = H5T.get_member_name(type_id,j-1);
%           member_value(j) = H5T.enum_valueof(type_id,member_name{j});
%       end
%
%   See also H5T, H5T.get_member_name, H5T.get_nmembers.

%   Copyright 2006-2013 The MathWorks, Inc.

value = H5ML.hdf5lib2('H5Tenum_valueof',type_id, name); 
