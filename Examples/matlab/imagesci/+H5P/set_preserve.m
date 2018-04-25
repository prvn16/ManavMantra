function set_preserve(plist_id, status)
%H5P.set_preserve  Set dataset transfer property status.
%
%   This function is no longer necessary.  Its functional capability is now
%   internal to the HDF5 library.  See the HDF5 User's Guide and Reference
%   Manual.
%
%   H5P.set_preserve(plist_id, status) sets the status of the dataset 
%   transfer property list, plist_id, to the specified Boolean value.
%
%   See also H5P.

%   Copyright 2006-2013 The MathWorks, Inc.

warning(message('MATLAB:imagesci:H5:setPreserveNoLongerUseful'));

H5ML.hdf5lib2('H5Pset_preserve', plist_id, status);
