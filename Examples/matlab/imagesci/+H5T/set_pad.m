function set_pad(type_id, lsb, msb)
%H5T.set_pad  Set padding type for least and most signicant bits.
%   H5T.set_pad(type_id, lsb, msb) sets the padding type for the least and
%   most-significant bits. type_id is the identifier of the datatype. lsb
%   specifies the padding type for least-significant bits; msb for
%   most-significant bits. Valid padding types are H5T_PAD_ZERO,
%   H5T_PAD_ONE, or H5T_PAD_BACKGROUND (leave background alone).
%
%   Example:
%       type_id = H5T.copy('H5T_NATIVE_INT');
%       lsb = H5ML.get_constant_value('H5T_PAD_ONE');
%       msb = H5ML.get_constant_value('H5T_PAD_ZERO');
%       H5T.set_pad(type_id,lsb,msb);
%
%   See also H5T, H5T.get_pad.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Tset_pad',type_id, lsb, msb); 
