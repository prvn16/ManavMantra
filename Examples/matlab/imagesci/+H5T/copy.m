function output = copy(type_id)
%H5T.copy  Copy datatype.
%   output_type_id = H5T.copy(type_id) copies the existing datatype
%   identifier, a dataset identifier specified by type_id, or a predefined
%   datatype such as 'H5T_NATIVE_DOUBLE'. output_type_id is a datatype
%   identifier.
%
%   Example:
%       type_id = H5T.copy('H5T_NATIVE_DOUBLE');
%       type_size = H5T.get_size(type_id);
%
%   See also H5T, H5T.get_size.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Tcopy', type_id);            
output = H5ML.id(output,'H5Tclose');
