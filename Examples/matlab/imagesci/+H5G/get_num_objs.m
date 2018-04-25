function num_objs = get_num_objs(loc_id)
%H5G.get_num_objs  Return number of objects in file or group.
%
%   H5G.get_num_objs is not recommended.  Use H5G.get_info instead.
%
%   num_objs = H5G.get_num_objs(loc_id) returns number of objects in the
%   group or file specified loc_id. 
%
%   The HDF5 group has deprecated the use of this function.
%
%   See also H5G, H5G.get_info.

%   Copyright 2006-2013 The MathWorks, Inc.

num_objs = H5ML.hdf5lib2('H5Gget_num_objs', loc_id);            
