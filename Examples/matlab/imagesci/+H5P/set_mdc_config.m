function set_mdc_config(plist_id,config)
%H5P.set_mdc_config  Set initial metadata cache configuration.
%   H5P.set_mdc_config(plist_id,config_struct) sets the initial metadata
%   cache configuration in the indicated file access property List to 
%   the supplied values. Before using this function, you should 
%   retrieve the current configuration using H5P.get_mdc_config.
%
%   Many of the fields in the config structure are intended to be used 
%   only in close consultation with the HDF5 Group itself.  
%
%   See also H5P, H5P.get_mdc_config.

%   Copyright 2009-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_mdc_config', plist_id,config);            
