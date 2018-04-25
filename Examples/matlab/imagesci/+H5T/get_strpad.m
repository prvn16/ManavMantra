function output = get_strpad(type_id)
%H5T.get_strpad  Return storage mechanism for string datatype.
%   output = H5T.get_strpad(type_id) returns the storage mechanism (padding
%   type) for a string datatype. Possible values are: 
%
%       H5T_STR_NULLPAD  - pad with zeros
%       H5T_STR_NULLTERM - null-terminate
%       H5T_STR_SPACEPAD - pad with spaces 
%
%   Example:  
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/string');
%       type_id = H5D.get_type(dset_id);
%       padding = H5T.get_strpad(type_id);
%       switch(padding)
%           case H5ML.get_constant_value('H5T_STR_NULLTERM')
%               fprintf('null-terminated\n');
%           case H5ML.get_constant_value('H5T_STR_NULLPAD')
%               fprintf('padded with zeros\n');
%           case H5ML.get_constant_value('H5T_STR_SPACEPAD')
%               fprintf('padded with spaces\n');
%       end
%           
%       
%   See also H5T, H5T.set_strpad.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Tget_strpad',type_id); 
