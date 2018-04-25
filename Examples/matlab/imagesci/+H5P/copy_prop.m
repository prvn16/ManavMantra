function copy_prop(dst_plist_id, src_plist_id, name) %#ok<INUSD>
%H5P.copy_prop  Copy specified property from source to destination.
%   H5P.copy_prop(dst_plist_id, src_plist_id, name) copies the property specified 
%   by name from the property list specified by src_plist_id to the property
%   list specified by dst_plist_id. 
% 
%   The HDF5 function 'H5Pcopy_prop' implementation in HDF library version
%   1.8.3 has a critical bug/issue. Hence this function is currently
%   disabled.
%
%   See also H5P.

%   Copyright 2006-2013 The MathWorks, Inc.

error(message('MATLAB:imagesci:H5:copy_prop_unsupported'));
