function [lsb, msb] = get_pad(type_id)
%H5T.get_pad  Return padding type of least and most-significant bits.
%   [lsb msb] = H5T.get_pad(type_id) Returns the padding type of the least 
%   and most-significant bit padding. type_id is a datatype identifier.
%   lsb is the least-significant bit padding type. msb is the most-significant
%   bit padding type.  Values for lsb and msb can either H5T_PAD_ZERO,
%   H5T_PAD_ONE, or H5T_PAD_BACKGROUND.
%
%   Example:
%        fid = H5F.open('example.h5');
%        dset_id = H5D.open(fid,'/g3/integer');
%        type_id = H5D.get_type(dset_id);
%        [lsb,msb] = H5T.get_pad(type_id);
%        switch(lsb)
%            case H5ML.get_constant_value('H5T_PAD_ZERO')
%                fprintf('lsb pad type is zeros\n');
%            case H5ML.get_constant_value('H5T_PAD_ONE');
%                fprintf('lsb pad type is ones\n');
%            case H5ML.get_constant_value('H5T_PAD_BACKGROUND')
%                fprintf('lsb pad type is background\n');
%        end
%        switch(msb)
%            case H5ML.get_constant_value('H5T_PAD_ZERO')
%                fprintf('msb pad type is zeros\n');
%            case H5ML.get_constant_value('H5T_PAD_ONE');
%                fprintf('msb pad type is ones\n');
%            case H5ML.get_constant_value('H5T_PAD_BACKGROUND')
%                fprintf('msb pad type is background\n');
%        end
%
%   See also H5T, H5T.set_pad.

%   Copyright 2006-2013 The MathWorks, Inc.

[lsb, msb] = H5ML.hdf5lib2('H5Tget_pad',type_id); 
