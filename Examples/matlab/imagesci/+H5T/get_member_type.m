function type_id = get_member_type(type_id, membno)
%H5T.get_member_type  Return datatype of specified member.
%   type_id = H5T.get_member_type(type_id, membno) returns the datatype of
%   the member specified by membno in the datatype specified by type_id.
%
%   Example:  get the size of the datatype of the first member of a
%   compound datatype.
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/compound');
%       compound_type_id = H5D.get_type(dset_id);
%       member_type_id = H5T.get_member_type(compound_type_id,0);
%       type_size = H5T.get_size(member_type_id);
%    
%   See also H5T, H5D.get_type.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Tget_member_type',type_id, membno); 
type_id = H5ML.id(output,'H5Tclose');
