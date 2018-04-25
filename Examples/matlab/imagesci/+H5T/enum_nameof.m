function name = enum_nameof(type_id, value)
%H5T.enum_nameof  Return name of specified enumeration datatype member.
%   name = H5T.enum_nameof(type, value) returns the symbol name
%   corresponding to a member of an enumeration datatype. type specifies
%   the enumeration datatype. value identifies the member of the
%   enumeration.
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/enum');
%       type_id = H5D.get_type(dset_id);
%       name0 = H5T.enum_nameof(type_id,int32(0));
%       name1 = H5T.enum_nameof(type_id,int32(1));
%
%   See also H5T, H5T.enum_valueof.

%   Copyright 2006-2013 The MathWorks, Inc.

name = H5ML.hdf5lib2('H5Tenum_nameof',type_id, value); 
