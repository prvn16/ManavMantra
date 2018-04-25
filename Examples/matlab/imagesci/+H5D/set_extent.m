function set_extent(dset_id, h5_extents)
%H5D.set_extent  Change size of dataset dimensions.
%   H5D.set_extent(dset_id,h5_extents) changes the dimensions of the 
%   dataset dset_id to the sizes specified in h5_extents.
%
%   Note:  The HDF5 library uses C-style ordering for multidimensional 
%   arrays, while MATLAB uses FORTRAN-style ordering. The h5_extents
%   parameter assumes C-style ordering. Please consult "Using the MATLAB
%   Low-Level HDF5 Functions" in the MATLAB documentation for more
%   information.  
%
%   Example:  Extend an unlimited one-dimensional dataset from a length of
%   10 to a length of 20.
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.h5');
%       copyfile(srcFile,'myfile.h5');
%       fileattrib('myfile.h5','+w');
%       fid = H5F.open('myfile.h5','H5F_ACC_RDWR','H5P_DEFAULT');
%       dset_id = H5D.open(fid,'/g4/time');
%       H5D.set_extent(dset_id,20);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5D.

%   Copyright 2009-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Dset_extent', dset_id, h5_extents);            


