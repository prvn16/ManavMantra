function setChunkCache(csize, nelems, premp)
%netcdf.setChunkCache Set default chunk cache settings.
%   netcdf.setChunkCache(csize, nelems, premp) sets the default chunk cache
%   settings. The settings apply for subsequent file open or create
%   operations. This function does not change the chunk cache settings of
%   files already open.
%
%   csize is the total size of the raw data chunk cache in bytes. nelems is
%   the number of chunk slots in the raw data chunk cache hash table.  This
%   should be a prime number larger than the number of chunks that will be
%   in the cache. premp is the preemtion value; it must be between 0 and 1
%   inclusive and indicates how many chunks that have been fully read are
%   favored for preemption. A value of zero means fully read chunks are
%   treated no differently than other chunks (the preemption is strictly
%   LRU) while a value of one means fully read chunks are always preempted
%   before other chunks.
%
%   This setting persists for the remainder of the MATLAB session or until
%   a 'clear mex' is issued.
%
%   This function corresponds to the "nc_set_chunk_cache" function in the 
%   netCDF library C API.
%
%   Example:
%        netcdf.setChunkCache(32000000, 2003, .75);  
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%  
%   See also netcdf, netcdf.getChunkCache.

%   Copyright 2011-2013 The MathWorks, Inc.

validateattributes(csize,{'numeric'},{'scalar'},'','CSIZE');
validateattributes(nelems,{'numeric'},{'scalar'},'','NELEMS');
validateattributes(premp,{'numeric'},{'scalar','>=',0,'<=',1},'','PREMP');

netcdflib('setChunkCache',csize, nelems, single(premp));
