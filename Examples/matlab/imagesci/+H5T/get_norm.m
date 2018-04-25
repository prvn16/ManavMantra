function output = get_norm(type_id)
%H5T.get_norm  Return mantissa normalization type.
%   norm_type = H5T.get_norm(type_id) returns the mantissa normalization of 
%   a floating-point datatype. type_id is a datatype identifier. norm_type 
%   can be H5T_NORM_IMPLIED, H5T_NORM_MSBSET, or H5T_NORM_NONE.
%
%    Example:
%        fid = H5F.open('example.h5');
%        dset_id = H5D.open(fid,'/g3/float');
%        type_id = H5D.get_type(dset_id);
%        norm_type = H5T.get_norm(type_id);
%        switch(norm_type)
%            case H5ML.get_constant_value('H5T_NORM_IMPLIED')
%                fprintf('MSB of mantissa is not stored, always 1\n');
%            case H5ML.get_constant_value('H5T_NORM_MSBSET');
%                fprintf('MSB of mantissa is always 1\n');
%            case H5ML.get_constant_value('H5T_NORM_NONE')
%                fprintf('mantissa is not normalized\n');
%        end
%
%   See also H5T, H5T.set_norm.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Tget_norm',type_id); 
