function array_type_id = array_create(varargin)
%H5T.array_create  Create array datatype object.
%   array_type_id = H5T.array_create(base_id,h5_dims) creates a new array 
%   datatype object.  This interface corresponds to the 1.8 library
%   version of H5Tarray_create.
%
%   array_type_id = H5T.array_create(base_id,rank,h5_dims,perms) creates a 
%   new array datatype object.  This interface corresponds to the 1.6 
%   library version of H5Tarray_create.  The perms parameter is not used
%   at this time and can be omitted.
%
%   Note:  The HDF5 library uses C-style ordering for multidimensional 
%   arrays, while MATLAB uses FORTRAN-style ordering. The h5_dims
%   parameter assumes C-style ordering. Please consult "Using the MATLAB 
%   Low-Level HDF5 Functions" in the MATLAB documentation for more 
%   information. 
%
%   Example:  create a 100x200 double precision array datatype.
%       base_type_id = H5T.copy('H5T_NATIVE_DOUBLE');
%       dims = [100 200];
%       h5_dims = fliplr(dims);
%       array_type = H5T.array_create(base_type_id,h5_dims);
%
%   See also H5T, H5T.get_array_dims, H5T.get_array_ndims.

%   Copyright 2006-2013 The MathWorks, Inc.

array_type_id = H5ML.hdf5lib2('H5Tarray_create', varargin{:});            
array_type_id = H5ML.id(array_type_id,'H5Tclose');
