function modify_filter(plist_id, filter_id, flags, cd_values)
%H5P.modify_filter  Modify filter in pipeline.
%   H5P.modify_filter(plist_id, filter_id, flags, cd_values) modifies the 
%   specified filter in the filter pipeline. plist_id is a property list 
%   identifier. flags is a bit vector specifying certain general properties
%   of the filter.  cd_values specifies auxiliary data for the filter.
%
%   See also H5P, H5P.get_filter, H5P.get_nfilters, H5P.get_filter_by_id,
%   H5P.remove_filter.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pmodify_filter', plist_id, filter_id, flags, cd_values);
