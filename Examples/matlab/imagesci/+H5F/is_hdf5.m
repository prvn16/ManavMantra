function value = is_hdf5(filename)
%H5F.is_hdf5  Determine if file is HDF5.
%   value = H5F.is_hdf5(name) returns a positive number if the file
%   specified by name is in the HDF5 format, and zero if it is not. A
%   negative return value indicates failure.
%
%   Example:
%       value = H5F.is_hdf5('example.tif');
%       if value > 0
%           fprintf('example.tif is an HDF5 file\n');
%       else
%           fprintf('example.tif is not an HDF5 file\n');
%       end
%
%   See also H5F.

%   Copyright 2006-2013 The MathWorks, Inc.

value = H5ML.hdf5lib2('H5Fis_hdf5', filename);            
