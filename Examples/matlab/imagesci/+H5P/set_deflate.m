function set_deflate(plist_id, level)
%H5P.set_deflate  Set compression method and compression level.
%   H5P.set_deflate(plist_id, level) sets the compression method for the 
%   dataset creation property list specified by plist_id to 
%   H5D_COMPRESS_DEFLATE. level specifies the compression level as a value
%   from 0 and 9, inclusive. Lower values results in less compression.
%
%   Example:  create a two dimensional double precision dataset that has an
%   initial size of [512 1024], but is also unlimited in both dimensions 
%   and has a chunk size of [512 1024] and a compression level of 5.
%       fid = H5F.create('myfile.h5');
%       type_id = H5T.copy('H5T_NATIVE_DOUBLE');
%       unlimited = H5ML.get_constant_value('H5S_UNLIMITED');
%       dims = [512 1024];
%       h5_dims = fliplr(dims);
%       h5_maxdims = [unlimited unlimited];
%       space_id = H5S.create_simple(2,[1024 512],h5_maxdims);
%       dcpl = H5P.create('H5P_DATASET_CREATE');
%       chunk_dims = [512 1024];
%       h5_chunk_dims = fliplr(chunk_dims);
%       H5P.set_chunk(dcpl,h5_chunk_dims);
%       H5P.set_deflate(dcpl,5);
%       dset_id = H5D.create(fid,'DS',type_id,space_id,dcpl);
%       H5D.close(dset_id);
%       H5F.close(fid);
%
%   See also H5P.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_deflate', plist_id, level);            
