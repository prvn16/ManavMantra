function output = get_member_offset(type_id, membno)
%H5T.get_member_offset  Return offset of field of compound datatype.
%   output = H5T.get_member_offset(type_id, membno) returns the byte offset 
%   of the field specified by membno in the compound datatype specified by
%   type_id. Note that zero (0) is a valid offset.
%
%   Example:
%      fid = H5F.open('example.h5');
%      dset_id = H5D.open(fid,'/g3/compound');
%      type_id = H5D.get_type(dset_id);
%      idx = H5T.get_member_offset(type_id,1); 
%
%   See also H5T, H5T.get_member_name.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Tget_member_offset',type_id, membno); 
