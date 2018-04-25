function [mdc_nelmts, rdcc_nelmts, rdcc_nbytes, rdcc_w0] = get_cache(plist_id)
%H5P.get_cache  Return metadata cache settings.
%   [mdc_nelmts rdcc_nelmts rdcc_nbytes rdcc_w0] = H5P.get_cache(plist_id)
%   returns the maximum possible number of elements in the meta data cache
%   (mdc_nelmts), the raw data chunk cache (rdcc_nelmts), the maximum
%   possible number of bytes in the raw data chunk cache (rdcc_nbytes), and
%   the preemption policy value (rdcc_w0) for the file access property list
%   specified by plist_id.
%
%   The HDF5 Group has deprecated the mdc_nelmts parameter since it is no
%   longer used. Please use H5P.get_mdc_config for metadata cache
%   configuration.  
%
%   See also H5P, H5P.set_cache, H5P.get_mdc_config, H5P.set_mdc_config, 
%   H5F.get_mdc_config, H5F.set_mdc_config.  
%   

%   Copyright 2006-2013 The MathWorks, Inc.

warning(message('MATLAB:imagesci:H5:getCacheDeprecated'));
[mdc_nelmts, rdcc_nelmts, rdcc_nbytes, rdcc_w0] = H5ML.hdf5lib2('H5Pget_cache', plist_id);            
