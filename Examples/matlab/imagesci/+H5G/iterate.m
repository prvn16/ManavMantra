function idx = iterate(loc_id, name, idx, iter_func)
%H5G.iterate  Iterate over group objects.
%
%   H5G.iterate is not recommended.  Use H5L.iterate instead.
%
%   output = H5G.iterate(loc_id, name, idx, iter_func) executes the 
%   operation iter_func on each entry in the file or group specified by 
%   loc_id. name specifies group over which the iteration is performed. 
%   idx specifies the location at which to begin the iteration.    
%   iter_func is a function handle.
%
%   The iterator function must have the following signature.
%
%       status = iter_func(loc_id,name)
%
%   loc_id still identifies the file or group passed into H5G.iterate, and 
%   name identifies the name of the current entry.
%
%   The HDF5 group has deprecated the use of this function.
%
%   See also H5G, H5L.iterate.

%   Copyright 2006-2013 The MathWorks, Inc.

idx = H5ML.hdf5lib2('H5Giterate', loc_id, name, idx, iter_func);            
