function sz = get_meta_block_size(fapl_id)
%H5P.get_meta_block_size  Return metadata block size setting.
%   sz = H5P.get_meta_block_size(fapl_id) returns the current minimum 
%   size, in bytes, of new metadata block allocations.
%
%   Example:
%       fid = H5F.open('example.h5');
%       fapl = H5F.get_access_plist(fid);
%       sz = H5P.get_meta_block_size(fapl);
%       H5P.close(fapl);
%       H5F.close(fid);
%
%   See also H5P, H5P.set_meta_block_size.

%   Copyright 2006-2013 The MathWorks, Inc.

sz = H5ML.hdf5lib2('H5Pget_meta_block_size', fapl_id);            
