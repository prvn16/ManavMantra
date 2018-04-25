function num_files = get_external_count(plist_id)
%H5P.get_external_count  Return count of external files.
%   num_files = H5P.get_external_count(plist_id) returns the number of
%   external files for the dataset creation property list, plist_id.
%
%   See also H5P, H5P.get_external.

%   Copyright 2006-2013 The MathWorks, Inc.

num_files = H5ML.hdf5lib2('H5Pget_external_count', plist_id);            
