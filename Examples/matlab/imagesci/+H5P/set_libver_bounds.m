function set_libver_bounds(fapl_id,low,high)
%H5P.set_libver_bounds  Set library version bounds for objects.
%   H5P.set_libver_bounds(fapl_id,low,high) sets bounds on library
%   versions, and indirectly format versions, to be used when creating
%   objects in the file with access property list fapl_id. Low must be set
%   to either of 'H5F_LIBVER_EARLIEST', 'H5F_LIBVER_18' or
%   'H5F_LIBVER_LATEST'. High must be set to 'H5F_LIBVER_18' or
%   'H5F_LIBVER_LATEST'.
%
%   Example:  Create an HDF5 file where objects are created using the 
%   latest available format for each object.
%      fcpl = H5P.create('H5P_FILE_CREATE');
%      fapl = H5P.create('H5P_FILE_ACCESS');
%      H5P.set_libver_bounds(fapl,'H5F_LIBVER_LATEST','H5F_LIBVER_LATEST');
%      fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',fcpl,fapl);
%
%   See also H5P, H5P.get_libver_bounds, H5ML.get_constant_value.
%         

%   Copyright 2006-2014 The MathWorks, Inc.


H5ML.hdf5lib2('H5Pset_libver_bounds',fapl_id,low,high);
