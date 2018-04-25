function value = get_member_value(type_id, membno)
%H5T.get_member_value  Return value of enumeration datatype member.
%   value = H5T.get_member_value(type_id, membno) returns the value of the
%   enumeration datatype member specified by membno. type_id is the
%   datatype identifier for the enumeration datatype.
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/enum');
%       type_id = H5D.get_type(dset_id);
%       num_members = H5T.get_nmembers(type_id);
%       for j = 1:num_members
%           member_name{j} = H5T.get_member_name(type_id,j-1);
%           member_value(j) = H5T.get_member_value(type_id,j-1);
%       end
%
%   See also H5T, H5T.get_member_name, H5T.get_nmembers.

%   Copyright 2006-2013 The MathWorks, Inc.

value = H5ML.hdf5lib2('H5Tget_member_value',type_id, membno); 
