function filter_config_flags = get_filter_info(filter)
%H5Z.get_filter_info  Return information about specified filter.
%   [filter_config_flags] = H5Z.get_filter_info(filter) retrieves
%   information about the filter specified by its identifier. At present,
%   the information returned is the filter's configuration flags,
%   indicating whether the filter is configured to decode data, to encode
%   data, neither, or both.  filter_config_flags should be used with the
%   HDF5 constant values H5Z_FILTER_CONFIG_ENCODE_ENABLED and
%   H5Z_FILTER_CONFIG_DECODE_ENABLED in a bitwise AND operation.  If the
%   resulting value is 0, then the encode or decode functionality is not
%   available.
%
%   Example:  determine if encoding is enabled for the deflate filter.
%       flags = H5Z.get_filter_info('H5Z_FILTER_DEFLATE');
%       functionality = H5ML.get_constant_value('H5Z_FILTER_CONFIG_ENCODE_ENABLED');
%       enabled = bitand(flags,functionality) > 0;
%      
%   See also H5Z, H5Z.filter_avail, H5ML.get_constant_value, bitand.

%   Copyright 2006-2013 The MathWorks, Inc.

try
	filter_config_flags = H5ML.hdf5lib2('H5Zget_filter_info', filter);            
catch me
	% This should be allowed to error in the next release.
	if ( strcmp(me.identifier,'MATLAB:imagesci:hdf5lib:libraryError') ...
        && strcmp(filter,'H5Z_FILTER_SZIP') )
		filter_config_flags = 0;
	else
		rethrow(me);
	end
end
