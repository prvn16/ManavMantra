function output = get_preserve(plist_id)
%H5P.get_preserve  Return status of dataset transfer property list.
%
%   This function is no longer necessary.  Its functional capability is now
%   internal to the HDF5 library.  See the HDF5 User's Guide and Reference
%   Manual.
%
%   output = H5P.get_preserve(plist_id) returns the status of the dataset
%   transfer property list.
%
%   See also H5P.

%   Copyright 2006-2013 The MathWorks, Inc.

warning(message('MATLAB:imagesci:H5:getPreserveNoLongerUseful'));

output = H5ML.hdf5lib2('H5Pget_preserve', plist_id );
