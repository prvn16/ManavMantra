function set_chunk(plist_id, h5_chunk_dims)
%H5P.set_chunk  Set chunk size.
%   H5P.set_chunk(plist_id, h5_chunk_dims) sets the size of the chunks used
%   to store a chunked layout dataset. plist_id is a dataset creation
%   property list identifier. h5_chunk_dims is an array specifying the
%   size, in dataset elements, of each chunk.
%
%   Note:  The HDF5 library uses C-style ordering for multidimensional 
%   arrays, while MATLAB uses FORTRAN-style ordering. The h5_chunk_dims
%   parameter assumes C-style ordering. Please consult "Using the MATLAB 
%   Low-Level HDF5 Functions" in the MATLAB documentation for more 
%   information. 
%
%   Example:  create a two dimensional double precision dataset that has an
%   initial size of [512 1024], but is also unlimited in both dimensions 
%   and has a chunk size of [512 1024].
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
%       dset_id = H5D.create(fid,'DS',type_id,space_id,dcpl);
%       H5D.close(dset_id);
%       H5F.close(fid);
% 
%   See also H5P, H5P.get_chunk.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_chunk', plist_id, h5_chunk_dims);            
