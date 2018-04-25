function set_sizes(fcpl, sizeof_addr, sizeof_size)
%H5P.set_sizes  Set byte size of offsets and lengths.
%   H5P.set_sizes(plist_id, sizeof_addr, sizeof_size) sets the byte size of
%   the offsets and lengths used to address objects in an HDF5 file.
%   plist_id is a file creation property list.
%
%   See also H5P, H5P.get_sizes.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_sizes', fcpl, sizeof_addr, sizeof_size);            
