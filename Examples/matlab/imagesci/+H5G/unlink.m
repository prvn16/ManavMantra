function unlink(loc_id, name)
%H5G.unlink  Remove link to object from group.
%
%   H5G.unlink is not recommended.  Use H5L.delete instead.
%
%   H5G.unlink(loc_id, name) removes the object specified by name from the
%   file or group specified by loc_id.
%
%   The HDF5 group has deprecated the use of this function.
%
%   See also H5G, H5L.delete.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Gunlink', loc_id, name);            
