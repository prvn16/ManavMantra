function output = equal(varargin)
%H5T.equal  Determine equality of datatypes.
%   output = H5T.equal(type1_id, type2_id) returns a positive number if the 
%   datatype identifiers refer to the same datatype, and zero to indicate 
%   that they do not.  A negative value indicates failure.  Either of the
%   input values could be a string corresponding to an HDF5 datatype.
%
%   Example:  Determine if the datatype of a dataset is a 32-bit little
%   endian integer.
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/integer2D');
%       dtype_id = H5D.get_type(dset_id);
%       if H5T.equal(dtype_id,'H5T_STD_I32LE')
%           fprintf('32-bit little endian integer\n');
%       end
%
%   See also H5T, H5D.get_type.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Tequal', varargin{:});            
