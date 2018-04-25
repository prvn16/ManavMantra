function total_attrs = get_num_attrs(loc_id)
%H5A.get_num_attrs  Return number of attributes attached to object.
%
%   H5A.get_num_attrs is not recommended.  Use H5O.get_info instead.
%
%   total_attrs = H5A.get_num_attrs(loc_id) returns the number of 
%   attributes attached to the group, dataset, or named datatype specified 
%   by loc_id.
%
%   The HDF5 group has deprecated the use of this function in favor of 
%   H5O.get_info.
%
%   For more help on the Attribute Interface functions, type:
%     help H5A
%   
%   See also H5O.get_info.

%   Copyright 2006-2013 The MathWorks, Inc.

total_attrs = H5ML.hdf5lib2('H5Aget_num_attrs', loc_id);            
