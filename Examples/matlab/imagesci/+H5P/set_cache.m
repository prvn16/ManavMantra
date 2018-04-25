function set_cache(plist_id, mdc_nelmts, rdcc_nelmts, rdcc_nbytes, rdcc_w0)
%H5P.set_cache  Set raw data chunk cache parameters.
%   H5P.set_cache(plist_id, mdc_nelmts, rdcc_nelmts, rdcc_nbytes, rdcc_w0)
%   sets the number of elements in the meta data cache (mdc_nelmts), and
%   the number of elements, the total number of bytes, and the preemption
%   policy value in the raw data chunk cache. plist_id is a file access
%   property list identifier.
%
%   The HDF5 Group has deprecated the mdc_nelmts parameter since it is no
%   longer used. Please use H5P.set_mdc_config for metadata cache
%   configuration. 
%
%   See also H5P, H5P.get_cache, H5P.get_mdc_config, H5P.set_mdc_config, 
%   H5F.get_mdc_config, H5F.set_mdc_config.  
%

%   Copyright 2006-2013 The MathWorks, Inc.

warning(message('MATLAB:imagesci:H5:setCacheDeprecated'));
H5ML.hdf5lib2('H5Pset_cache', plist_id, mdc_nelmts, rdcc_nelmts, rdcc_nbytes, rdcc_w0);            
