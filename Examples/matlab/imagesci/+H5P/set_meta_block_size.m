function set_meta_block_size(fapl_id, sz)
%H5P.set_meta_block_size  Set minimum metadata block size.
%   H5P.set_meta_block_size(fapl_id, size) sets the minimum metadata block 
%   size for the file access property list specified by fapl_id. size 
%   specifies minimum size, in bytes, of metadata block allocations.
%
%   Example:
%       fcpl = H5P.create('H5P_FILE_CREATE');
%       fapl = H5P.create('H5P_FILE_ACCESS');
%       H5P.set_meta_block_size(fapl,4096);
%       fid = H5F.create('myfile.h5','H5F_ACC_TRUNC',fcpl,fapl);
%       H5F.close(fid);
%
%   See also H5P, H5P.get_meta_block_size;

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_meta_block_size', fapl_id, sz);            
