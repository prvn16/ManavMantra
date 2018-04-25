function output = get_sign(type_id)
%H5T.get_sign  Return sign type for intege datatype.
%   sign_type = H5T.get_sign(type_id) returns the sign type for an integer
%   type. type_id is a datatype identifier. Valid types are: H5T_SGN_NONE
%   or H5T_SGN_2.
%
%   Example:
%        fid = H5F.open('example.h5');
%        dset_id = H5D.open(fid,'/g3/integer');
%        type_id = H5D.get_type(dset_id);
%        sign_type = H5T.get_sign(type_id);
%        switch(sign_type)
%            case H5ML.get_constant_value('H5T_SGN_NONE')
%                fprintf('Unsigned integer type.\n');
%            case H5ML.get_constant_value('H5T_SGN_2');
%                fprintf('Signed integer type.\n');
%        end
%
%   See also H5T, H5T.set_sign.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Tget_sign',type_id); 
