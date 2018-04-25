function [sizeof_addr, sizeof_size] = get_sizes(fcpl)
%H5P.get_sizes  Return size of offsets and lengths.
%   [sizeof_addr sizeof_size] = H5P.get_sizes(fcpl) returns the size of 
%   the offsets and lengths used in an HDF5 file. fcpl specifies a file
%   creation property list.
%
%   Example:
%       fid = H5F.open('example.h5');
%       fcpl = H5F.get_create_plist(fid);
%       [soaddr, sosize] = H5P.get_sizes(fcpl);
%       H5P.close(fcpl);
%       H5F.close(fid);
%
%   See also H5P, H5P.set_sizes.

%   Copyright 2006-2013 The MathWorks, Inc.

[sizeof_addr, sizeof_size] = H5ML.hdf5lib2('H5Pget_sizes', fcpl);            
