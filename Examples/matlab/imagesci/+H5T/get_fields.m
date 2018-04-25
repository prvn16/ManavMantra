function [spos, epos, esize, mpos, msize] = get_fields(type_id)
%H5T.get_fields  Return floating point datatype bit field information.
%   [spos epos esize mpos msize] = H5T.get_fields(type_id) returns information
%   about the locations of the various bit fields of a floating point datatype.
%   type_id is a datatype identifier. spos is the floating-point sign bit. 
%   epos is the exponent bit-position. esize is the size of the exponent in
%   bits. mpos is the mantissa bit-position. msize is the size of the mantissa
%   in bits.
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/float');
%       type_id = H5D.get_type(dset_id);
%       [spos, epos, esize, mpos, msize] = H5T.get_fields(type_id);
%
%   See also H5T.

%   Copyright 2006-2013 The MathWorks, Inc.

[spos, epos, esize, mpos, msize] = H5ML.hdf5lib2('H5Tget_fields', type_id); 

