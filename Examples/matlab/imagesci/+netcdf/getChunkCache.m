function [csize, nelems, premp] = getChunkCache()
%netcdf.getChunkCache Return default chunk cache settings.
%   [csize, nelems, premp] = netcdf.getChunkCache() gets the default chunk
%   cache settings. csize is the total size of the raw data chunk cache in
%   bytes. nelems is the number of chunk slots in the raw data chunk cache
%   hash table.  premp is the preemption value, between 0 and 1 inclusive,
%   and indicates how many chunks that have been fully read are favored for
%   preemption. A value of zero means fully read chunks are treated no
%   differently than other chunks (the preemption is strictly LRU) while a
%   value of one means fully read chunks are always preempted before other
%   chunks.
%
%   This function corresponds to the "nc_get_chunk_cache" function in the 
%   netCDF library C API.
%
%   Example:
%      [csize, nelems, premp] = netcdf.getChunkCache();
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%  
%   See also netcdf, netcdf.setChunkCache.

%   Copyright 2011-2013 The MathWorks, Inc.

[csize, nelems, premp] = netcdflib('getChunkCache');
