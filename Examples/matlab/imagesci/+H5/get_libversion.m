function [majnum, minnum, relnum] = get_libversion
%H5.get_libversion  Return version of HDF5 library.
%   [majnum minnum relnum] = H5.get_libversion() returns the version of the HDF5
%   library in use.
%
%   See also H5.

%   Copyright 2006-2013 The MathWorks, Inc.

[majnum, minnum, relnum] = H5ML.hdf5lib2('H5get_libversion');            
