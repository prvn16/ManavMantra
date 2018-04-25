function hit_rate = get_mdc_hit_rate(file_id)
%H5F.get_mdc_hit_rate  Return metadata cache hit rate.
%   hitRate = H5F.get_mdc_hit_rate(file_id) queries the metadata cache
%   of the target file to obtain its hit rate since the last time hit 
%   rate statistics were reset. If the cache has not been accessed since 
%   the last time the hit rate stats were reset, the hit rate is defined 
%   to be 0.0.  The hit rate is calculated as
%
%       (cache hits / (cache hits + cache misses))
%
%   Example:
%       fid = H5F.open('example.h5');
%       hit_rate = H5F.get_mdc_hit_rate(fid);
%       H5F.close(fid);
%
%   See also H5F, H5F.get_mdc_config.

%   Copyright 2006-2013 The MathWorks, Inc.

hit_rate = H5ML.hdf5lib2('H5Fget_mdc_hit_rate',file_id);            
