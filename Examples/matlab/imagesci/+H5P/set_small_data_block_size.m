function set_small_data_block_size(fapl_id, sz)
%H5P.set_small_data_block_size  Set size of block reserved for small data.
%   H5P.set_small_data_block_size(fapl_id, size) sets the maximum size, in 
%   bytes, of a contiguous block reserved for small data. fapl_id is a file 
%   access property list identifier.
%
%   Example:
%       fcpl = H5P.create('H5P_FILE_CREATE');
%       fapl = H5P.create('H5P_FILE_ACCESS');
%       H5P.set_small_data_block_size(fapl,4096);
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',fcpl,fapl);
%       H5F.close(fid);
%
%   See also H5P, H5P.get_small_data_block_size.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_small_data_block_size', fapl_id, sz);            
