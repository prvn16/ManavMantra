function output = get_nfilters(plist_id)
%H5P.get_nfilters  Return number of filters in pipeline.
%   num_filters = H5P.get_nfilters(plist_id) returns the number of filters
%   defined in the filter pipeline associated with the dataset creation
%   property list, plist_id.
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g4/world');
%       dcpl = H5D.get_create_plist(dset_id);
%       num_filters = H5P.get_nfilters(dcpl);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5P, H5P.get_filter, H5P.get_filter_by_id, H5P.modify_filter,
%   H5P.remove_filter.

%   Copyright 2006-2013 The MathWorks, Inc.

output = H5ML.hdf5lib2('H5Pget_nfilters', plist_id);            
