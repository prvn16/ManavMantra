function attr_id = open_name(loc_id,name)
%H5A.open_name  Open attribute specified by name.
%
%   H5A.open_name is not recommended.  Use H5A.open_by_name instead.
%
%   attr_id = H5A.open_name(loc_id,name) opens the attribute specified by
%   name, which is attached to the group, dataset, or named datatype
%   specified by loc_id.
%
%   The HDF5 group has deprecated the use of this function.
%  
%   See also H5A, H5A.open, H5A.open_by_name.

%   Copyright 2006-2013 The MathWorks, Inc.

attr_id = H5ML.hdf5lib2('H5Aopen_name', loc_id,name);            
attr_id = H5ML.id(attr_id,'H5Aclose');

