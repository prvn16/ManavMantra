function [numdims, h5_dims, h5_maxdims] = get_simple_extent_dims(space_id)
%H5S.get_simple_extent_dims  Return size and maximum size of dataspace.
%   [numdims h5_dims h5_maxdims] = H5S.get_simple_extent_dims(space_id) 
%   returns the number of dimensions in the dataspace, the size of each
%   dimension, and the maximum size of each dimension. 
%
%   Note:  The HDF5 library uses C-style ordering for multidimensional 
%   arrays, while MATLAB uses FORTRAN-style ordering. The h5_dims and
%   h5_maxdims assume C-style ordering. Please consult "Using the MATLAB
%   Low-Level HDF5 Functions" in the MATLAB documentation for more
%   information.  
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g2/dset2.2');
%       space_id = H5D.get_space(dset_id);
%       [ndims,h5_dims] = H5S.get_simple_extent_dims(space_id);
%       matlab_dims = fliplr(h5_dims);
%
%   See also H5S.

%   Copyright 2006-2013 The MathWorks, Inc.

[numdims, h5_dims, h5_maxdims] = H5ML.hdf5lib2('H5Sget_simple_extent_dims', space_id);            
