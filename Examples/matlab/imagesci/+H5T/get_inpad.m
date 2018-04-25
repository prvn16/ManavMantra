function output = get_inpad(type_id)
%H5T.get_inpad  Return internal padding type for floating point datatypes.
%   pad_type = H5T.get_inpad(type_id) returns the internal padding type for
%   unused bits in floating-point datatypes. type_id is a datatype 
%   identifier.  pad_type can be H5T_PAD_ZERO, H5T_PAD_ONE, or 
%   H5T_PAD_BACKGROUND.
%
%    Example:
%        fid = H5F.open('example.h5');
%        dset_id = H5D.open(fid,'/g3/float');
%        type_id = H5D.get_type(dset_id);
%        pad_type = H5T.get_inpad(type_id);
%        switch(pad_type)
%            case H5ML.get_constant_value('H5T_PAD_ZERO')
%                fprintf('pad zero\n');
%            case H5ML.get_constant_value('H5T_PAD_ONE');
%                fprintf('pad one\n');
%            case H5ML.get_constant_value('H5T_PAD_BACKGROUND')
%                fprintf('pad background\n');
%        end
%
%   See also H5T, H5T.set_inpad.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Tget_inpad',type_id); 
