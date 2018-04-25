function varargout = get_filter(plist_id, index)
%H5P.get_filter  Return information about filter in pipeline.
%   [filter flags cd_values name] = H5P.get_filter(plist_id, index) returns
%   information about the filter, specified by its filter index, in the
%   filter pipeline, specified by the property list with which it is
%   associated.  This interface corresponds to the 1.6 version of
%   H5Pget_filter in the HDF5 library.
%
%   [filter flags cd_values name filter_config] = H5P.get_filter(plist_id,index) 
%   returns information about the filter, specified by its filter index, in
%   the filter pipeline, specified by the property list with which it is
%   associated.  It also returns information about the filter.  Consult the
%   HDF5 documentation for H5Zget_filter_info for information about
%   filter_config.  This interface corresponds to the 1.8 version of
%   H5Pget_filter in the HDF5 library.
%
%   See also H5P, H5P.get_nfilters, H5P.get_filter_by_id,
%   H5P.modify_filter, H5P.remove_filter.

%   Copyright 2006-2013 The MathWorks, Inc.

varargout = cell(1,nargout);
[varargout{:}] = H5ML.hdf5lib2('H5Pget_filter', plist_id, index);            
